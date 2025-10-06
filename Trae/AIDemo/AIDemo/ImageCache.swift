import UIKit

final class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let accessQueue = DispatchQueue(label: "com.aidemo.imagecache.access", attributes: .concurrent)
    private var accessCount: [String: Int] = [:] // Track access frequency
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // Register for memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func image(forKey key: String) -> UIImage? {
        accessQueue.async(flags: .barrier) { [weak self] in
            self?.accessCount[key, default: 0] += 1
        }
        // TODO: 性能优化 - 无去重下载，易并发重复拉取同一 URL
        // 优化方案：
        // 1. ImageCache 增加 in-flight 任务去重字典
        // 2. 使用 actor 或锁机制避免重复下载
        // 代码示例：
        // private var loadingTasks: [String: Task<UIImage?, Error>] = [:]
        // if let existingTask = loadingTasks[key] {
        //     return try? await existingTask.value
        // }
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        // Calculate approximate cost based on image dimensions
        let cost = image.size.width * image.size.height * 4 // width * height * 4 bytes per pixel
        // TODO: 性能优化 - 增加 downsampling；内存告警清理缓存
        // 优化方案：
        // 1. 使用 ImageIO 框架的 CGImageSourceCreateThumbnailAtIndex 进行 downsampling
        // 2. 根据显示尺寸限制最大像素，减少内存占用
        // 代码示例：
        // let source = CGImageSourceCreateWithData(data, nil)
        // let options: [CFString: Any] = [
        //     kCGImageSourceThumbnailMaxPixelSize: 120, // 60x60 * 2 (Retina)
        //     kCGImageSourceCreateThumbnailFromImageAlways: true
        // ]
        // let cgImage = CGImageSourceCreateThumbnailAtIndex(source!, 0, options as CFDictionary)
        cache.setObject(image, forKey: key as NSString, cost: Int(cost))
        
        accessQueue.async(flags: .barrier) { [weak self] in
            self?.accessCount[key] = 1
        }
    }
    
    func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        
        accessQueue.async(flags: .barrier) { [weak self] in
            self?.accessCount.removeValue(forKey: key)
        }
    }
    
    @objc func clearCache() {
        cache.removeAllObjects()
        
        accessQueue.async(flags: .barrier) { [weak self] in
            self?.accessCount.removeAll()
        }
        print("Image cache cleared due to memory warning")
    }
    
    func removeLeastRecentlyUsed() {
        accessQueue.sync {
            let sortedKeys = accessCount.sorted { $0.value < $1.value }
            if let leastUsedKey = sortedKeys.first?.key {
                cache.removeObject(forKey: leastUsedKey as NSString)
                accessCount.removeValue(forKey: leastUsedKey)
            }
        }
    }
    
    func getCacheInfo() -> (count: Int, totalCost: Int, accessStats: [String: Int]) {
        return accessQueue.sync {
            (cache.countLimit, cache.totalCostLimit, accessCount)
        }
    }
}