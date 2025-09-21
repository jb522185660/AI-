import Foundation
import UIKit

@MainActor
class PhotoListViewModel {
    var photos: [Photo] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    weak var delegate: PhotoListViewModelDelegate?
    
    private let urlSession = URLSession.shared
    private let photosURL = "https://example.com/photos"
    
    init() {
        Task {
            await loadPhotos()
        }
    }
    
    func loadPhotos() async {
        isLoading = true
        errorMessage = nil
        delegate?.viewModelDidUpdateLoadingState(self)
        
        do {
            // Mock data since the API doesn't exist
            let mockPhotos = createMockPhotos()
            photos = mockPhotos
            
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            delegate?.viewModelDidUpdatePhotos(self)
            
        } catch {
            errorMessage = "Failed to load photos: \(error.localizedDescription)"
            delegate?.viewModelDidUpdateError(self)
        }
        
        isLoading = false
        delegate?.viewModelDidUpdateLoadingState(self)
    }
    
    func refresh() async {
        await loadPhotos()
    }
    
    private func createMockPhotos() -> [Photo] {
        return [
            Photo(id: 1, title: "Beautiful Sunset", url: "https://picsum.photos/300/200?random=1"),
            Photo(id: 2, title: "Mountain View", url: "https://picsum.photos/300/200?random=2"),
            Photo(id: 3, title: "Ocean Waves", url: "https://picsum.photos/300/200?random=3"),
            Photo(id: 4, title: "Forest Path", url: "https://picsum.photos/300/200?random=4"),
            Photo(id: 5, title: "City Lights", url: "https://picsum.photos/300/200?random=5"),
            Photo(id: 6, title: "Desert Landscape", url: "https://picsum.photos/300/200?random=6"),
            Photo(id: 7, title: "Snowy Mountains", url: "https://picsum.photos/300/200?random=7"),
            Photo(id: 8, title: "Lake Reflection", url: "https://picsum.photos/300/200?random=8"),
            Photo(id: 9, title: "Flower Garden", url: "https://picsum.photos/300/200?random=9"),
            Photo(id: 10, title: "Starry Night", url: "https://picsum.photos/300/200?random=10")
        ]
    }
    
    // Real API implementation (commented out since API doesn't exist)
    /*
    private func fetchPhotosFromAPI() async throws -> [Photo] {
        guard let url = URL(string: photosURL) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([Photo].self, from: data)
    }
    */
}

protocol PhotoListViewModelDelegate: AnyObject {
    func viewModelDidUpdatePhotos(_ viewModel: PhotoListViewModel)
    func viewModelDidUpdateLoadingState(_ viewModel: PhotoListViewModel)
    func viewModelDidUpdateError(_ viewModel: PhotoListViewModel)
}