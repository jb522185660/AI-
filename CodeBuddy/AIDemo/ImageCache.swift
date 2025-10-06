import UIKit

// TODO: 代码生成能力测试中ImageCache 采用 actor 去重并发下载
actor ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private var loadingTasks: [String: Task<UIImage?, Error>] = [:]
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func image(for urlString: String) async -> UIImage? {
        let key = urlString as NSString
        
        // 检查内存缓存
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        // 检查是否有正在进行的加载任务
        if let existingTask = loadingTasks[urlString] {
            return try? await existingTask.value
        }
        
        // 创建新的加载任务
        let task = Task<UIImage?, Error> {
            defer { loadingTasks.removeValue(forKey: urlString) }
            
            guard let url = URL(string: urlString) else {
                return nil
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else {
                    return nil
                }
                
                // 缓存图片
                cache.setObject(image, forKey: key)
                return image
            } catch {
                print("图片加载失败: \(error)")
                return nil
            }
        }
        
        loadingTasks[urlString] = task
        return try? await task.value
    }
    
    func clearCache() {
        cache.removeAllObjects()
        loadingTasks.removeAll()
    }
}
