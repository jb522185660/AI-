import UIKit

class PhotoDetailViewController: UIViewController {
    
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
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private var favoriteButton: UIBarButtonItem!
    private var isFavorite: Bool = false {
        didSet {
            updateFavoriteButtonAppearance()
        }
    }
    
    // UserDefaults 键
    private let favoritesKey = "FavoritePhotos"
    
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
        setupFavoriteButton()
        loadImage()
        checkIfFavorite()
    }
    
    private func setupUI() {
        title = "照片详情"
        view.backgroundColor = .systemBackground
        
        // 添加图片视图
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0)
        ])
        
        // 添加标题标签
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // 设置标题
        titleLabel.text = photo.title
    }
    
    private func setupFavoriteButton() {
        favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    // TODO: 上下文理解与持续开发中，与原MVVM/Combine 代码风格一致；图片加载复用ViewModel，整体连贯
    private func loadImage() {
        Task {
            if let image = await viewModel.loadImage(for: photo) {
                await MainActor.run {
                    self.imageView.image = image
                }
            }
        }
    }
    
    private func checkIfFavorite() {
        let favorites = getFavoritePhotos()
        isFavorite = favorites.contains { $0.id == photo.id }
    }
    
    private func updateFavoriteButtonAppearance() {
        let imageName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.image = UIImage(systemName: imageName)
        favoriteButton.tintColor = isFavorite ? .systemRed : .systemBlue
    }
    
    @objc private func toggleFavorite() {
        var favorites = getFavoritePhotos()
        
        if isFavorite {
            // 取消收藏
            favorites.removeAll { $0.id == photo.id }
            showToast(message: "已取消收藏")
        } else {
            // 添加收藏
            favorites.append(photo)
            showToast(message: "已添加到收藏")
        }
        
        // 保存更新后的收藏列表
        saveFavoritePhotos(favorites)
        
        // 更新状态
        isFavorite.toggle()
    }
    
    private func getFavoritePhotos() -> [Photo] {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey) else {
            return []
        }
        
        do {
            let favorites = try JSONDecoder().decode([Photo].self, from: data)
            return favorites
        } catch {
            print("获取收藏失败: \(error)")
            return []
        }
    }
    
    private func saveFavoritePhotos(_ photos: [Photo]) {
        do {
            let data = try JSONEncoder().encode(photos)
            UserDefaults.standard.set(data, forKey: favoritesKey)
        } catch {
            print("保存收藏失败: \(error)")
        }
    }
    
    private func showToast(message: String) {
        let toast = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(toast, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            toast.dismiss(animated: true)
        }
    }
}
