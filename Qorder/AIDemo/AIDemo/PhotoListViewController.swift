import UIKit

class PhotoListViewController: UIViewController {
    
    private let viewModel = PhotoListViewModel()
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
    }
    
    private func setupUI() {
        title = "Photos"
        view.backgroundColor = .systemBackground
        
        // Setup table view
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PhotoTableViewCell.self, forCellReuseIdentifier: "PhotoCell")
        tableView.rowHeight = 100
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Use performBatchUpdates for better animation performance
        tableView.performBatchUpdates {
            // Only reload the favorites section to avoid full table reload
            if !FavoriteManager.shared.getFavorites().isEmpty {
                tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
        }
    }
    
    @objc private func refreshData() {
        Task {
            await viewModel.refresh()
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PhotoListViewModelDelegate
extension PhotoListViewController: PhotoListViewModelDelegate {
    func viewModelDidUpdatePhotos(_ viewModel: PhotoListViewModel) {
        tableView.reloadData()
    }
    
    func viewModelDidUpdateLoadingState(_ viewModel: PhotoListViewModel) {
        if !viewModel.isLoading {
            refreshControl.endRefreshing()
        }
    }
    
    func viewModelDidUpdateError(_ viewModel: PhotoListViewModel) {
        if let error = viewModel.errorMessage {
            showError(error)
        }
    }
}

// MARK: - UITableViewDataSource
extension PhotoListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Favorites section + All photos section
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return FavoriteManager.shared.getFavorites().count
        } else {
            return viewModel.photos.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return FavoriteManager.shared.getFavorites().isEmpty ? nil : "收藏"
        } else {
            return "全部照片"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoTableViewCell
        
        let photo: Photo
        if indexPath.section == 0 {
            let favorites = FavoriteManager.shared.getFavorites()
            guard indexPath.row < favorites.count else {
                return cell // Return empty cell if index out of bounds
            }
            photo = favorites[indexPath.row]
        } else {
            guard indexPath.row < viewModel.photos.count else {
                return cell // Return empty cell if index out of bounds
            }
            photo = viewModel.photos[indexPath.row]
        }
        
        cell.configure(with: photo)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PhotoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedPhoto: Photo
        if indexPath.section == 0 {
            let favorites = FavoriteManager.shared.getFavorites()
            guard indexPath.row < favorites.count else { return }
            selectedPhoto = favorites[indexPath.row]
        } else {
            guard indexPath.row < viewModel.photos.count else { return }
            selectedPhoto = viewModel.photos[indexPath.row]
        }
        
        let detailViewController = PhotoDetailViewController(photo: selectedPhoto)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - PhotoTableViewCell
class PhotoTableViewCell: UITableViewCell {
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var imageLoadTask: Task<Void, Never>?
    
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
        photoImageView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 80),
            photoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor)
        ])
    }
    
    func configure(with photo: Photo) {
        // Cancel previous task to prevent race conditions
        imageLoadTask?.cancel()
        
        titleLabel.text = photo.title
        photoImageView.image = nil
        activityIndicator.startAnimating()
        
        imageLoadTask = Task {
            let image = await ImageCache.shared.loadImage(from: photo.url)
            
            // Check if task was cancelled
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                guard !Task.isCancelled else { return }
                activityIndicator.stopAnimating()
                photoImageView.image = image ?? UIImage(systemName: "photo")
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        photoImageView.image = nil
        titleLabel.text = nil
        activityIndicator.stopAnimating()
    }
}