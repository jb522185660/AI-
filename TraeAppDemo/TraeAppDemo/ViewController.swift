//
//  ViewController.swift
//  TraeAppDemo
//
//  Created by JackLi on 2025/9/27.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Home"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome to your dashboard"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    // MARK: - Card Views
    private let optionsCard: CardView = {
        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.configure(with: "Options", subtitle: "Manage your settings", iconName: "home_icon", color: .systemBlue)
        return card
    }()
    
    private let cameraCard: CardView = {
        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.configure(with: "Camera", subtitle: "Take photos and videos", iconName: "camera_icon", color: .systemGreen)
        return card
    }()
    
    private let incidentsCard: CardView = {
        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.configure(with: "Incidents", subtitle: "Report and track issues", iconName: "light_bulb_icon", color: .systemOrange)
        return card
    }()
    
    private let buildingCard: CardView = {
        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.configure(with: "Building", subtitle: "Manage properties", iconName: "building_icon", color: .systemPurple)
        return card
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(optionsCard)
        contentView.addSubview(cameraCard)
        contentView.addSubview(incidentsCard)
        contentView.addSubview(buildingCard)
        
        // Add tap gestures to cards
        let optionsTap = UITapGestureRecognizer(target: self, action: #selector(optionsCardTapped))
        optionsCard.addGestureRecognizer(optionsTap)
        
        let cameraTap = UITapGestureRecognizer(target: self, action: #selector(cameraCardTapped))
        cameraCard.addGestureRecognizer(cameraTap)
        
        let incidentsTap = UITapGestureRecognizer(target: self, action: #selector(incidentsCardTapped))
        incidentsCard.addGestureRecognizer(incidentsTap)
        
        let buildingTap = UITapGestureRecognizer(target: self, action: #selector(buildingCardTapped))
        buildingCard.addGestureRecognizer(buildingTap)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Subtitle label constraints
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Cards constraints
            optionsCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            optionsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            optionsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            optionsCard.heightAnchor.constraint(equalToConstant: 100),
            
            cameraCard.topAnchor.constraint(equalTo: optionsCard.bottomAnchor, constant: 16),
            cameraCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cameraCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cameraCard.heightAnchor.constraint(equalToConstant: 100),
            
            incidentsCard.topAnchor.constraint(equalTo: cameraCard.bottomAnchor, constant: 16),
            incidentsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            incidentsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            incidentsCard.heightAnchor.constraint(equalToConstant: 100),
            
            buildingCard.topAnchor.constraint(equalTo: incidentsCard.bottomAnchor, constant: 16),
            buildingCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buildingCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buildingCard.heightAnchor.constraint(equalToConstant: 100),
            buildingCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Card Tap Actions
    @objc private func optionsCardTapped() {
        showAlert(title: "Options", message: "Options card tapped")
    }
    
    @objc private func cameraCardTapped() {
        showAlert(title: "Camera", message: "Camera card tapped")
    }
    
    @objc private func incidentsCardTapped() {
        showAlert(title: "Incidents", message: "Incidents card tapped")
    }
    
    @objc private func buildingCardTapped() {
        showAlert(title: "Building", message: "Building card tapped")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

