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
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        // Calculate approximate cost based on image dimensions
        let cost = image.size.width * image.size.height * 4 // width * height * 4 bytes per pixel
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