//
//  ViewController.swift
//  Speer-Task
//
//  Created by Ajay Sarkate on 03/01/24.
//

import UIKit

class ViewController: UIViewController {
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter GitHub username"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(usernameTextField)
        view.addSubview(searchButton)
        
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            searchButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    @objc private func searchButtonTapped() {
        guard let username = usernameTextField.text, !username.isEmpty else {
            // Handle empty username
            return
        }
        
        fetchUserData(username: username)
    }
    
    private func fetchUserData(username: String) {
        let username2 = username.lowercased()
        let apiUrl = "https://api.github.com/users/\(username2)"
        
        // Use URLSession to make the API request
        URLSession.shared.dataTask(with: URL(string: apiUrl)!) { data, _, error in
            if let error = error {
                print("Error fetching user data:", error)
                // Handle error
                return
            }
            
            guard let data = data else {
                print("No data received")
                // Handle missing data
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let gitHubUser = try decoder.decode(GitHubUser.self, from: data)
                
                DispatchQueue.main.async {
                    // Navigate to UserProfileViewController with the fetched user data
                    let userProfileVC = UserProfileViewController()
                    userProfileVC.user = gitHubUser
                    self.present(userProfileVC, animated: true)
                }
            } catch {
                print("Error decoding JSON:", error)
                
                DispatchQueue.main.async {
                    // Show "Not found" alert or navigate to a "Not found" view
                    self.showNotFoundAlert()
                }
            }
        }.resume()
    }
    
    private func showNotFoundAlert() {
        // We can use alert also if we want to
        let alert = UIAlertController(title: "User Not Found", message: "The specified GitHub user was not found.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
//        let userNotFoundVC = UserNotFoundViewController()
//        self.present(userNotFoundVC, animated: true)
    }
}




