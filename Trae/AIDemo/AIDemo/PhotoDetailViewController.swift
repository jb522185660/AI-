import UIKit

extension Notification.Name {
    static let favoritesChanged = Notification.Name("favoritesChanged")
}

final class PhotoDetailViewController: UIViewController {
    
    private let photo: Photo
    private let viewModel: PhotoListViewModel
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var favoriteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )
        button.tintColor = .systemRed
        return button
    }()
    
    private var isFavorite: Bool {
        FavoriteManager.shared.isFavorite(photo: photo)
    }
    
    init(photo: Photo, viewModel: PhotoListViewModel) {
        self.photo = photo
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        configureWithPhoto()
        loadImage()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(activityIndicator)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = favoriteButton
        updateFavoriteButtonAppearance()
    }
    
    private func configureWithPhoto() {
        titleLabel.text = photo.title
        title = "Photo Details"
    }
    
    private func loadImage() {
        activityIndicator.startAnimating()
        // TODO: 连续上下文中，延续原Combine 绑定方式，连续性最好。
        Task {
            if let image = await viewModel.loadImage(from: photo.url) {
                await MainActor.run {
                    self.imageView.image = image
                    self.activityIndicator.stopAnimating()
                }
            } else {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showErrorAlert()
                }
            }
        }
    }
    
    @objc private func toggleFavorite() {
        if isFavorite {
            FavoriteManager.shared.removeFavorite(photo: photo)
        } else {
            FavoriteManager.shared.addFavorite(photo: photo)
        }
        updateFavoriteButtonAppearance()
        showFavoriteToast()
        
        // Notify that favorites have changed
        NotificationCenter.default.post(name: .favoritesChanged, object: nil)
    }
    
    private func updateFavoriteButtonAppearance() {
        favoriteButton.image = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
    }
    
    private func showFavoriteToast() {
        let message = isFavorite ? "Added to favorites" : "Removed from favorites"
        
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.9)
        toastLabel.textColor = .label
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        view.addSubview(toastLabel)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            toastLabel.widthAnchor.constraint(equalToConstant: 200),
            toastLabel.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load image",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// TODO: 连续上下文中，通过FavoriteManager来管理收藏
final class FavoriteManager {
    static let shared = FavoriteManager()
    
    private let favoritesKey = "favorite_photos"
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    func addFavorite(photo: Photo) {
        var favorites = getFavorites()
        if !favorites.contains(where: { $0.id == photo.id }) {
            favorites.append(photo)
            saveFavorites(favorites)
        }
    }
    
    func removeFavorite(photo: Photo) {
        var favorites = getFavorites()
        favorites.removeAll { $0.id == photo.id }
        saveFavorites(favorites)
    }
    
    func isFavorite(photo: Photo) -> Bool {
        let favorites = getFavorites()
        return favorites.contains { $0.id == photo.id }
    }
    
    func getFavorites() -> [Photo] {
        guard let data = userDefaults.data(forKey: favoritesKey) else { return [] }
        do {
            return try JSONDecoder().decode([Photo].self, from: data)
        } catch {
            print("Failed to decode favorites: \(error)")
            return []
        }
    }
    
    private func saveFavorites(_ favorites: [Photo]) {
        do {
            let data = try JSONEncoder().encode(favorites)
            userDefaults.set(data, forKey: favoritesKey)
        } catch {
            print("Failed to encode favorites: \(error)")
        }
    }
}
