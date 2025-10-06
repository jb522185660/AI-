import UIKit

// TODO: 代码生成能力测试中ImageCache 采用 actor 去重并发下载
actor ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private var loadingTasks: [String: Task<UIImage?, Error>] = [:]
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        // TODO: 性能优化 - 内存告警时清理缓存（监听UIApplication.didReceiveMemoryWarningNotification）
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
                // TODO: 性能优化 - URLCache 结合 ETag/Last-Modified，避免重复网络传输
                // 优化方案：
                // 1. 创建自定义 URLSessionConfiguration，启用 URLCache
                // 2. 配置缓存策略：.useProtocolCachePolicy
                // 3. 设置缓存容量：URLCache(memoryCapacity: 50MB, diskCapacity: 200MB)
                // 4. 服务器返回 ETag/Last-Modified 头，客户端发送 If-None-Match/If-Modified-Since
                // 代码示例：
                // let config = URLSessionConfiguration.default
                // config.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 200 * 1024 * 1024)
                // let session = URLSession(configuration: config)
                // let (data, response) = try await session.data(from: url)
                let (data, _) = try await URLSession.shared.data(from: url)
                // TODO: 性能优化 - 使用 downsampling 按目标尺寸解码，减少内存峰值
                // 优化方案：
                // 1. 使用 ImageIO 框架的 CGImageSourceCreateThumbnailAtIndex
                // 2. 根据显示尺寸（如 60x60）计算缩放比例
                // 3. 设置 kCGImageSourceThumbnailMaxPixelSize 限制最大像素
                // 4. 避免直接 UIImage(data:) 解码大图，减少内存峰值
                // 代码示例：
                // let source = CGImageSourceCreateWithData(data, nil)
                // let options: [CFString: Any] = [
                //     kCGImageSourceThumbnailMaxPixelSize: 120, // 60x60 * 2 (Retina)
                //     kCGImageSourceCreateThumbnailFromImageAlways: true
                // ]
                // let cgImage = CGImageSourceCreateThumbnailAtIndex(source!, 0, options as CFDictionary)
                // let image = UIImage(cgImage: cgImage!)
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
    // TODO: 性能优化 - 添加内存警告处理方法
}
