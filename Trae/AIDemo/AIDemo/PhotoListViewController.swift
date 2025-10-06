import UIKit
// TODO: 代码生成能力中，没有import Combine导致编译失败
import Combine

final class PhotoListViewController: UIViewController {
    
    private let viewModel = PhotoListViewModel()
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    
    private var favoritePhotos: [Photo] = []
    private var allPhotos: [Photo] = []
    
    private enum Section: Int, CaseIterable {
        case favorites
        case allPhotos
        
        var title: String {
            switch self {
            case .favorites: return "Favorites"
            case .allPhotos: return "All Photos"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadData()
    }
    
    private func setupUI() {
        title = "Photos"
        view.backgroundColor = .systemBackground
        
        // Setup TableView
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        view.addSubview(tableView)
        
        // Setup Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupBindings() {
        // TODO: 代码生成能力中，控制器通过Combine 绑定状态
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$photos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photos in
                guard let self = self else { return }
                self.allPhotos = photos
                self.updateFavoritePhotos()
                
                // Only reload if view is visible
                if self.isViewLoaded && self.view.window != nil {
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showErrorAlert(message: errorMessage)
                }
            }
            .store(in: &cancellables)
        
        // Listen for favorite changes with debounce
        NotificationCenter.default.publisher(for: .favoritesChanged)
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateFavoritePhotos()
                
                // Only reload if view is visible
                if self.isViewLoaded && self.view.window != nil {
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateFavoritePhotos() {
        favoritePhotos = allPhotos.filter { photo in
            FavoriteManager.shared.isFavorite(photo: photo)
        }
    }
    
    private func loadData() {
        Task {
            await viewModel.loadPhotos()
        }
    }
    
    // TODO: 代码生成能力测试中，支持刷新、缓存与异步图片加载
    @objc private func refreshData() {
        Task {
            await viewModel.loadPhotos()
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension PhotoListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .favorites:
            return favoritePhotos.count
        case .allPhotos:
            return allPhotos.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = Section(rawValue: section) else { return nil }
        return sectionType.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as? PhotoCell else {
            return UITableViewCell()
        }
        
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return cell
        }
        
        let photo: Photo
        switch sectionType {
        case .favorites:
            photo = favoritePhotos[indexPath.row]
        case .allPhotos:
            photo = allPhotos[indexPath.row]
        }
        
        cell.configure(with: photo, viewModel: viewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let sectionType = Section(rawValue: indexPath.section) else { return }
        
        let photo: Photo
        switch sectionType {
        case .favorites:
            photo = favoritePhotos[indexPath.row]
        case .allPhotos:
            photo = allPhotos[indexPath.row]
        }
        
        let detailVC = PhotoDetailViewController(photo: photo, viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - PhotoCell
final class PhotoCell: UITableViewCell {
    static let reuseIdentifier = "PhotoCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(titleLabel)
        
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 60),
            photoImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with photo: Photo, viewModel: PhotoListViewModel) {
        titleLabel.text = photo.title
        
        // Cancel previous loading task if any
        photoImageView.image = nil
        
        // Set placeholder or check cache first
        if let cachedImage = ImageCache.shared.image(forKey: photo.url) {
            photoImageView.image = cachedImage
            return
        }
        
        // TODO: 代码生成能力中实现异步加载
        Task {
            let image = await viewModel.loadImage(from: photo.url)
            
            // Ensure we're still displaying the same photo
            if self.titleLabel.text == photo.title {
                await MainActor.run {
                    self.photoImageView.image = image
                }
            }
        }
    }
}


