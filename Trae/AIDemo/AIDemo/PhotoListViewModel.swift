import Foundation
import UIKit

@MainActor
final class PhotoListViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func loadPhotos() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let photos = try await networkService.fetchPhotos()
            self.photos = photos
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadImage(from urlString: String) async -> UIImage? {
        // Check cache first
        if let cachedImage = ImageCache.shared.image(forKey: urlString) {
            return cachedImage
        }
        
        // Validate URL
        guard let url = URL(string: urlString), url.scheme != nil else {
            return nil
        }
        
        // Load image with timeout and error handling
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Validate HTTP response
            if let httpResponse = response as? HTTPURLResponse, 
               !(200...299).contains(httpResponse.statusCode) {
                print("HTTP error: \(httpResponse.statusCode)")
                return nil
            }
            
            // Validate image data
            if let image = UIImage(data: data) {
                ImageCache.shared.setImage(image, forKey: urlString)
                return image
            } else {
                print("Invalid image data for URL: \(urlString)")
                return nil
            }
        } catch {
            print("Failed to load image: \(error.localizedDescription)")
            return nil
        }
    }
}

protocol NetworkServiceProtocol {
    func fetchPhotos() async throws -> [Photo]
}

struct NetworkService: NetworkServiceProtocol {
    func fetchPhotos() async throws -> [Photo] {
        // Mock data for demonstration
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        
        return [
            Photo(id: 1, title: "Beautiful Sunset", url: "https://picsum.photos/200/300?random=1"),
            Photo(id: 2, title: "Mountain View", url: "https://picsum.photos/200/300?random=2"),
            Photo(id: 3, title: "Ocean Waves", url: "https://picsum.photos/200/300?random=3"),
            Photo(id: 4, title: "Forest Path", url: "https://picsum.photos/200/300?random=4"),
            Photo(id: 5, title: "City Lights", url: "https://picsum.photos/200/300?random=5"),
            Photo(id: 6, title: "Desert Landscape", url: "https://picsum.photos/200/300?random=6"),
            Photo(id: 7, title: "Winter Wonderland", url: "https://picsum.photos/200/300?random=7"),
            Photo(id: 8, title: "Spring Flowers", url: "https://picsum.photos/200/300?random=8"),
            Photo(id: 9, title: "Autumn Leaves", url: "https://picsum.photos/200/300?random=9"),
            Photo(id: 10, title: "Summer Beach", url: "https://picsum.photos/200/300?random=10")
        ]
    }
}