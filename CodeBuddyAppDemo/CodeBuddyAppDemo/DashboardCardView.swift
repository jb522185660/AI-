//
//  DashboardCardView.swift
//  CodeBuddyAppDemo
//
//  Created by JackLi on 2025/9/27.
//

import UIKit

class DashboardCardView: UIView {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = FontManager.shared.montserratBold(size: 16)
        label.textColor = .white
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: iconImageView.leadingAnchor, constant: -8),
            
            iconImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Configuration
    func configure(title: String, backgroundColor: UIColor, iconName: String) {
        containerView.backgroundColor = backgroundColor
        titleLabel.text = title
        
        // For now, using system icons - in production you would use actual icons from assets
        switch iconName {
        case "sos_icon":
            iconImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        case "security_icon":
            iconImageView.image = UIImage(systemName: "shield.fill")
        case "environment_icon":
            iconImageView.image = UIImage(systemName: "leaf.fill")
        case "development_icon":
            iconImageView.image = UIImage(systemName: "chart.bar.fill")
        default:
            iconImageView.image = UIImage(systemName: "questionmark.circle.fill")
        }
        
        iconImageView.tintColor = .white
    }
}