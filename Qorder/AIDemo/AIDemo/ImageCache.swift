import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let urlSession = URLSession.shared
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func image(for url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }
    
    func setImage(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
    
    @MainActor
    func loadImage(from url: String) async -> UIImage? {
        // Check cache first
        if let cachedImage = image(for: url) {
            return cachedImage
        }
        
        // Download image
        guard let imageURL = URL(string: url) else { return nil }
        
        do {
            let (data, _) = try await urlSession.data(from: imageURL)
            guard let image = UIImage(data: data) else { return nil }
            
            // Cache the image
            setImage(image, for: url)
            return image
        } catch {
            print("Failed to load image from \(url): \(error)")
            return nil
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}