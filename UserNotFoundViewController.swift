//
//  UserNotFoundViewController.swift
//  Speer-Task
//
//  Created by Ajay Sarkate on 03/01/24.
//

import UIKit

class UserNotFoundViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        
        let label = UILabel()
        label.text = "User Not Found"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 24)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 50),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
}


//


