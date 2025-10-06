import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    // TODO: 代码生成能力，使用NSCache来做缓存
    private let cache = NSCache<NSString, UIImage>()
    private let urlSession: URLSession
    private var activeTasks = [String: Task<UIImage?, Never>]()
    private let taskQueue = DispatchQueue(label: "ImageCacheQueue", attributes: .concurrent)
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // Configure URLSession for better performance
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024)
        config.requestCachePolicy = .returnCacheDataElseLoad
        urlSession = URLSession(configuration: config)
    }
    
    func image(for url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }
    
    func setImage(_ image: UIImage, for url: String) {
        let cost = Int(image.size.width * image.size.height * 4) // Approximate memory cost
        cache.setObject(image, forKey: url as NSString, cost: cost)
    }
    
    @MainActor
    func loadImage(from url: String) async -> UIImage? {
        // Check cache first
        if let cachedImage = image(for: url) {
            return cachedImage
        }
        
        // Check if there's already an active task for this URL
        if let existingTask = activeTasks[url] {
            return await existingTask.value
        }
        
        // Create new task
        let task = Task<UIImage?, Never> {
            await downloadImage(from: url)
        }
        
        activeTasks[url] = task
        let result = await task.value
        activeTasks.removeValue(forKey: url)
        
        return result
    }
    
    private func downloadImage(from url: String) async -> UIImage? {
        guard let imageURL = URL(string: url) else { return nil }
        
        do {
            let (data, response) = try await urlSession.data(from: imageURL)
            
            // Validate response
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                print("Invalid HTTP response for \(url)")
                return nil
            }
            
            // Create image with automatic decompression
            guard let image = UIImage(data: data) else {
                print("Failed to create image from data for \(url)")
                return nil
            }
            
            // Decompress image on background thread for better scrolling performance
            let decompressedImage = await decompressImage(image)
            
            // Cache the decompressed image
            await MainActor.run {
                setImage(decompressedImage, for: url)
            }
            
            return decompressedImage
        } catch {
            print("Failed to load image from \(url): \(error)")
            return nil
        }
    }
    
    private func decompressImage(_ image: UIImage) async -> UIImage {
        return await withCheckedContinuation { continuation in
            taskQueue.async {
                let size = image.size
                UIGraphicsBeginImageContextWithOptions(size, false, 0)
                image.draw(in: CGRect(origin: .zero, size: size))
                let decompressedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
                UIGraphicsEndImageContext()
                continuation.resume(returning: decompressedImage)
            }
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
