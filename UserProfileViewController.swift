//
//  UserProfileViewController.swift
//  Speer-Task
//
//  Created by Ajay Sarkate on 03/01/24.
//

import UIKit

class UserProfileViewController: UIViewController {
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let followersButton: UIButton = {
        let button = UIButton()
        button.setTitle("Followers", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let followingButton: UIButton = {
        let button = UIButton()
        button.setTitle("Following", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var user: GitHubUser? // Use the GitHubUser model
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(bioLabel)
        view.addSubview(followersButton)
        view.addSubview(followingButton)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 20),
            bioLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bioLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            followersButton.topAnchor.constraint(equalTo: bioLabel.bottomAnchor),
            followersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            followingButton.topAnchor.constraint(equalTo: followersButton.bottomAnchor),
            followingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ])
        
        followersButton.addTarget(self, action: #selector(followersButtonTapped), for: .touchUpInside)
        followingButton.addTarget(self, action: #selector(followingButtonTapped), for: .touchUpInside)
    }
    
    private func updateUI() {
        guard let user = user else {
            // Handle missing user data
            return
        }
        
        nameLabel.text = user.name
        usernameLabel.text = user.login
        bioLabel.text = user.bio
        followersButton.setTitle("\(user.followers) followers", for: .normal)
        followingButton.setTitle("\(user.following) following", for: .normal)
        
        // Load avatar image asynchronously
        DispatchQueue.global().async {
            if let url = URL(string: user.avatar_url),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.avatarImageView.image = image
                }
            }
        }
    }
    
    @objc private func followersButtonTapped() {
        fetchFollowers()
    }
    
    @objc private func followingButtonTapped() {
        fetchFollowing()
    }
    
    private func fetchFollowers() {
        guard let followersUrl = user?.followers_url else {
            // Handle missing followers URL
            return
        }
        
        // Use URLSession to make the API request for followers
        URLSession.shared.dataTask(with: URL(string: followersUrl)!) { data, _, error in
            if let error = error {
                print("Error fetching followers:", error)
                // Handle error
                return
            }
            
            guard let data = data else {
                print("No followers data received")
                // Handle missing data
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let followers = try decoder.decode([Follower].self, from: data)
                
                DispatchQueue.main.async {
                    // Navigate to FollowersViewController with the fetched followers data
                    let followersVC = FollowersViewController()
                    followersVC.users = followers
                    self.present(followersVC, animated: true)
                }
            } catch {
                print("Error decoding followers JSON:", error)
            }
        }.resume()
    }
    
    private func fetchFollowing() {
        guard let followingUrl = user?.following_url else {
            return
        }
        
        let cleanedFollowingUrl = followingUrl.replacingOccurrences(of: "{/other_user}", with: "")
        
        // Use URLSession to make the API request for followers
        URLSession.shared.dataTask(with: URL(string: cleanedFollowingUrl)!) { data, _, error in
            if let error = error {
                print("Error fetching followers:", error)
                return
            }
            
            guard let data = data else {
                print("No followers data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let following = try decoder.decode([Following].self, from: data)
                
                DispatchQueue.main.async {
                    // Navigate to FollowingViewController with the fetched followers data
                    let followingVC = FollowingViewController()
                    followingVC.users = following
                    self.present(followingVC, animated: true)
                }
            } catch {
                print("Error decoding following JSON:", error)
            }
        }.resume()
    }
}

// View Controller to see the followers of user

class FollowersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var users: [Follower] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Followers"
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "followerCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followerCell", for: indexPath)
        let follower = users[indexPath.row]
        cell.textLabel?.text = follower.login
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row]
        
        // 1. Get login from the selected follower
        let login = selectedUser.login
        
        // 2. Use the login to fetch the GitHubUser
        fetchGitHubUser(login: login)
    }
    
    private func fetchGitHubUser(login: String) {
        let gitHubUserUrl = "https://api.github.com/users/\(login)"
        
        URLSession.shared.dataTask(with: URL(string: gitHubUserUrl)!) { data, _, error in
            if let error = error {
                print("Error fetching GitHubUser:", error)
                // Handle error
                return
            }
            
            guard let data = data else {
                print("No GitHubUser data received")
                // Handle missing data
                return
            }
            
            do {
                // 3. Decode the GitHubUser from the fetched data
                let decoder = JSONDecoder()
                let gitHubUser = try decoder.decode(GitHubUser.self, from: data)
                
                DispatchQueue.main.async {
                    // 4. Navigate to UserProfileViewController with the fetched GitHubUser
                    let userProfileVC = UserProfileViewController()
                    userProfileVC.user = gitHubUser
                    self.present(userProfileVC, animated: true)
                }
            } catch {
                print("Error decoding GitHubUser JSON:", error)
            }
        }.resume()
    }
    
}

// View Controller to see the followings of user

class FollowingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var users: [Following] = [] // Assume GitHubUser is your data model
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Followers"
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "followerCell")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followerCell", for: indexPath)
        let follower = users[indexPath.row]
        cell.textLabel?.text = follower.login
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row]
        
        // 1. Get login from the selected follower
        let login = selectedUser.login
        
        // 2. Use the login to fetch the GitHubUser
        fetchGitHubUser(login: login)
    }
    
    private func fetchGitHubUser(login: String) {
        let gitHubUserUrl = "https://api.github.com/users/\(login)"
        
        URLSession.shared.dataTask(with: URL(string: gitHubUserUrl)!) { data, _, error in
            if let error = error {
                print("Error fetching GitHubUser:", error)
                // Handle error
                return
            }
            
            guard let data = data else {
                print("No GitHubUser data received")
                // Handle missing data
                return
            }
            
            do {
                // 3. Decode the GitHubUser from the fetched data
                let decoder = JSONDecoder()
                let gitHubUser = try decoder.decode(GitHubUser.self, from: data)
                
                DispatchQueue.main.async {
                    // 4. Navigate to UserProfileViewController with the fetched GitHubUser
                    let userProfileVC = UserProfileViewController()
                    userProfileVC.user = gitHubUser
                    self.present(userProfileVC, animated: true)
                }
            } catch {
                print("Error decoding GitHubUser JSON:", error)
            }
        }.resume()
    }

}

