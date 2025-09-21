import UIKit

class PhotoDetailViewController: UIViewController {
    
    private let photo: Photo
    private var isFavorited: Bool = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var favoriteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(favoriteButtonTapped)
        )
        return button
    }()
    
    init(photo: Photo) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPhotoData()
        checkFavoriteStatus()
    }
    
    private func setupUI() {
        title = "Photo Detail"
        view.backgroundColor = .systemBackground
        
        // Setup navigation bar button
        navigationItem.rightBarButtonItem = favoriteButton
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(photoImageView)
        contentView.addSubview(titleLabel)
        photoImageView.addSubview(activityIndicator)
        
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
            
            // PhotoImageView constraints
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor, multiplier: 0.75),
            
            // TitleLabel constraints
            titleLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // ActivityIndicator constraints
            activityIndicator.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor)
        ])
    }
    
    private func loadPhotoData() {
        titleLabel.text = photo.title
        activityIndicator.startAnimating()
        
        Task {
            let image = await ImageCache.shared.loadImage(from: photo.url)
            await MainActor.run {
                activityIndicator.stopAnimating()
                photoImageView.image = image ?? UIImage(systemName: "photo.fill")
            }
        }
    }
    
    private func checkFavoriteStatus() {
        isFavorited = FavoriteManager.shared.isFavorited(photoId: photo.id)
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        let imageName = isFavorited ? "heart.fill" : "heart"
        let color: UIColor = isFavorited ? .systemRed : .label
        
        favoriteButton.image = UIImage(systemName: imageName)
        favoriteButton.tintColor = color
    }
    
    @objc private func favoriteButtonTapped() {
        isFavorited.toggle()
        
        if isFavorited {
            FavoriteManager.shared.addFavorite(photo: photo)
            showFeedback(message: "已收藏")
        } else {
            FavoriteManager.shared.removeFavorite(photoId: photo.id)
            showFeedback(message: "已取消收藏")
        }
        
        updateFavoriteButton()
    }
    
    private func showFeedback(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        // Auto dismiss after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true)
        }
    }
}

// MARK: - FavoriteManager
class FavoriteManager {
    static let shared = FavoriteManager()
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoritePhotos"
    
    // Cache favorites in memory to avoid repeated UserDefaults access
    private var cachedFavorites: [Photo]?
    private let cacheQueue = DispatchQueue(label: "FavoriteCacheQueue", attributes: .concurrent)
    
    private init() {
        // Preload favorites on init
        loadFavoritesFromDefaults()
    }
    
    func addFavorite(photo: Photo) {
        cacheQueue.async(flags: .barrier) {
            var favorites = self.cachedFavorites ?? []
            
            // Check if already exists
            if !favorites.contains(where: { $0.id == photo.id }) {
                favorites.append(photo)
                self.cachedFavorites = favorites
                self.saveFavoritesToDefaults(favorites)
            }
        }
    }
    
    func removeFavorite(photoId: Int) {
        cacheQueue.async(flags: .barrier) {
            var favorites = self.cachedFavorites ?? []
            favorites.removeAll { $0.id == photoId }
            self.cachedFavorites = favorites
            self.saveFavoritesToDefaults(favorites)
        }
    }
    
    func isFavorited(photoId: Int) -> Bool {
        return cacheQueue.sync {
            return cachedFavorites?.contains { $0.id == photoId } ?? false
        }
    }
    
    func getFavorites() -> [Photo] {
        return cacheQueue.sync {
            return cachedFavorites ?? []
        }
    }
    
    private func loadFavoritesFromDefaults() {
        cacheQueue.async(flags: .barrier) {
            guard let data = self.userDefaults.data(forKey: self.favoritesKey),
                  let favorites = try? JSONDecoder().decode([Photo].self, from: data) else {
                self.cachedFavorites = []
                return
            }
            self.cachedFavorites = favorites
        }
    }
    
    private func saveFavoritesToDefaults(_ favorites: [Photo]) {
        // Save on background queue to avoid blocking UI
        DispatchQueue.global(qos: .utility).async {
            guard let data = try? JSONEncoder().encode(favorites) else { return }
            self.userDefaults.set(data, forKey: self.favoritesKey)
        }
    }
}