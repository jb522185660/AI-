//
//  DashboardViewController.swift
//  CodeBuddyAppDemo
//
//  Created by JackLi on 2025/9/27.
//

import UIKit

class DashboardViewController: UIViewController {
    
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
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bienvenido\nAlejandro M."
        label.numberOfLines = 0
        label.font = FontManager.shared.montserratBold(size: 24)
        label.textColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1.0)
        return label
    }()
    
    private let reportIncidentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Reporta una incidencia"
        label.font = FontManager.shared.montserratBold(size: 16)
        label.textColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1.0)
        return label
    }()
    
    // MARK: - Card Views
    private let sosCard: DashboardCardView = {
        let card = DashboardCardView()
        card.configure(
            title: "Incidencias\nS.O.S",
            backgroundColor: UIColor(red: 235/255, green: 87/255, blue: 87/255, alpha: 1.0),
            iconName: "sos_icon"
        )
        return card
    }()
    
    private let securityCard: DashboardCardView = {
        let card = DashboardCardView()
        card.configure(
            title: "Seguridad\nCiudadana",
            backgroundColor: UIColor(red: 45/255, green: 156/255, blue: 219/255, alpha: 1.0),
            iconName: "security_icon"
        )
        return card
    }()
    
    private let environmentCard: DashboardCardView = {
        let card = DashboardCardView()
        card.configure(
            title: "Gestión\nAmbiental",
            backgroundColor: UIColor(red: 112/255, green: 143/255, blue: 59/255, alpha: 1.0),
            iconName: "environment_icon"
        )
        return card
    }()
    
    private let developmentCard: DashboardCardView = {
        let card = DashboardCardView()
        card.configure(
            title: "Desarrollo\nSostenible",
            backgroundColor: UIColor(red: 253/255, green: 188/255, blue: 49/255, alpha: 1.0),
            iconName: "development_icon"
        )
        return card
    }()
    
    private let routesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ver rutas"
        label.font = FontManager.shared.montserratBold(size: 16)
        label.textColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1.0)
        return label
    }()
    
    private let routesButton: DashboardLargeButton = {
        let button = DashboardLargeButton()
        button.configure(
            title: "Rutas de\nCamiones de basura",
            backgroundColor: UIColor(red: 112/255, green: 143/255, blue: 59/255, alpha: 1.0),
            iconName: "truck_icon"
        )
        return button
    }()
    
    private let historyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Historial"
        label.font = FontManager.shared.montserratBold(size: 16)
        label.textColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1.0)
        return label
    }()
    
    private let historyButton: DashboardLargeButton = {
        let button = DashboardLargeButton()
        button.configure(
            title: "Historial de\nincidencias",
            backgroundColor: UIColor(red: 253/255, green: 188/255, blue: 49/255, alpha: 1.0),
            iconName: "history_icon"
        )
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add all components to content view
        contentView.addSubview(welcomeLabel)
        contentView.addSubview(reportIncidentLabel)
        contentView.addSubview(sosCard)
        contentView.addSubview(securityCard)
        contentView.addSubview(environmentCard)
        contentView.addSubview(developmentCard)
        contentView.addSubview(routesLabel)
        contentView.addSubview(routesButton)
        contentView.addSubview(historyLabel)
        contentView.addSubview(historyButton)
        
        // Add tap gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        sosCard.addGestureRecognizer(tapGesture)
        securityCard.addGestureRecognizer(tapGesture)
        environmentCard.addGestureRecognizer(tapGesture)
        developmentCard.addGestureRecognizer(tapGesture)
        routesButton.addGestureRecognizer(tapGesture)
        historyButton.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 900),
            
            // Welcome Label
            welcomeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 86),
            welcomeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // Report Incident Label
            reportIncidentLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 80),
            reportIncidentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            // Card Grid - First Row
            sosCard.topAnchor.constraint(equalTo: reportIncidentLabel.bottomAnchor, constant: 20),
            sosCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            sosCard.widthAnchor.constraint(equalToConstant: 165),
            sosCard.heightAnchor.constraint(equalToConstant: 80),
            
            securityCard.topAnchor.constraint(equalTo: sosCard.topAnchor),
            securityCard.leadingAnchor.constraint(equalTo: sosCard.trailingAnchor, constant: 6),
            securityCard.widthAnchor.constraint(equalToConstant: 165),
            securityCard.heightAnchor.constraint(equalToConstant: 80),
            
            // Card Grid - Second Row
            environmentCard.topAnchor.constraint(equalTo: sosCard.bottomAnchor, constant: 8),
            environmentCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            environmentCard.widthAnchor.constraint(equalToConstant: 165),
            environmentCard.heightAnchor.constraint(equalToConstant: 80),
            
            developmentCard.topAnchor.constraint(equalTo: environmentCard.topAnchor),
            developmentCard.leadingAnchor.constraint(equalTo: environmentCard.trailingAnchor, constant: 6),
            developmentCard.widthAnchor.constraint(equalToConstant: 165),
            developmentCard.heightAnchor.constraint(equalToConstant: 80),
            
            // Routes Section
            routesLabel.topAnchor.constraint(equalTo: environmentCard.bottomAnchor, constant: 56),
            routesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            routesButton.topAnchor.constraint(equalTo: routesLabel.bottomAnchor, constant: 16),
            routesButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            routesButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            routesButton.heightAnchor.constraint(equalToConstant: 80),
            
            // History Section
            historyLabel.topAnchor.constraint(equalTo: routesButton.bottomAnchor, constant: 40),
            historyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            historyButton.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 16),
            historyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            historyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            historyButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Actions
    @objc private func handleCardTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        if view == sosCard {
            print("SOS Card tapped")
        } else if view == securityCard {
            print("Security Card tapped")
        } else if view == environmentCard {
            print("Environment Card tapped")
        } else if view == developmentCard {
            print("Development Card tapped")
        } else if view == routesButton {
            print("Routes Button tapped")
        } else if view == historyButton {
            print("History Button tapped")
        }
    }
}