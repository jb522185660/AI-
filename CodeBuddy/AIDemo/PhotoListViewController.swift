import UIKit

class PhotoListViewController: UIViewController {
    
    private let viewModel = PhotoListViewModel()
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var cancellables = Set<AnyCancellable>()
    private var favoritePhotos: [Photo] = []
    private let favoritesKey = "FavoritePhotos"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let oldCount = favoritePhotos.count
        loadFavoritePhotos()
        
        // 只在收藏数据变化时刷新表格
        if favoritePhotos.count != oldCount {
            tableView.reloadData()
        }
    }
    
    private func loadFavoritePhotos() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey) else {
            favoritePhotos = []
            return
        }
        
        do {
            let newFavorites = try JSONDecoder().decode([Photo].self, from: data)
            favoritePhotos = newFavorites
        } catch {
            print("获取收藏失败: \(error)")
            // 数据损坏时清空收藏
            UserDefaults.standard.removeObject(forKey: favoritesKey)
            favoritePhotos = []
        }
    }
    
    private func setupUI() {
        title = "照片列表"
        view.backgroundColor = .systemBackground
        
        // 设置表格视图，修改为分组样式
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(PhotoCell.self, forCellReuseIdentifier: "PhotoCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        view.addSubview(tableView)
        
        // 设置下拉刷新
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupBindings() {
        viewModel.$photos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showError(message: errorMessage)
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadData() {
        Task {
            await viewModel.loadPhotos()
        }
    }
    
    @objc private func handleRefresh() {
        Task {
            await viewModel.refresh()
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension PhotoListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // 收藏分区和全部照片分区
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "收藏" : "全部照片"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section >= 0 && section < 2 else { return 0 }
        return section == 0 ? favoritePhotos.count : viewModel.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        // 安全地获取照片数据，防止数组越界
        guard indexPath.section >= 0 && indexPath.section < 2 else {
            return cell
        }
        
        let photos = indexPath.section == 0 ? favoritePhotos : viewModel.photos
        guard indexPath.row >= 0 && indexPath.row < photos.count else {
            return cell
        }
        
        let photo = photos[indexPath.row]
        cell.configure(with: photo, viewModel: viewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 安全地获取照片数据，防止数组越界
        guard indexPath.section >= 0 && indexPath.section < 2 else {
            return
        }
        
        let photos = indexPath.section == 0 ? favoritePhotos : viewModel.photos
        guard indexPath.row >= 0 && indexPath.row < photos.count else {
            return
        }
        
        let photo = photos[indexPath.row]
        
        // 创建并跳转到详情页
        let detailVC = PhotoDetailViewController(photo: photo, viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - 自定义单元格
class PhotoCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private var currentTask: Task<Void, Never>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 60),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with photo: Photo, viewModel: PhotoListViewModel) {
        titleLabel.text = photo.title
        thumbnailImageView.image = nil
        
        // 取消之前的任务
        currentTask?.cancel()
        
        // 加载图片
        currentTask = Task {
            if let image = await viewModel.loadImage(for: photo) {
                await MainActor.run {
                    if !Task.isCancelled {
                        self.thumbnailImageView.image = image
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        currentTask = nil
        thumbnailImageView.image = nil
    }
}

// Combine 支持
import Combine