import Foundation
import UIKit

@MainActor
class PhotoListViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let imageCache = ImageCache.shared
    
    func loadPhotos() async {
        isLoading = true
        errorMessage = nil
        
        // TODO: 代码生成能力测试中，未实现对https://example.com/photos 的URLSession 解码。
        
        do {
            // 使用模拟数据替代网络请求
            try await Task.sleep(nanoseconds: 1_000_000_000) // 模拟网络延迟
            let mockPhotos = MockPhotoService.mockPhotos()
            
            photos = mockPhotos
        } catch {
            errorMessage = "加载失败: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func loadImage(for photo: Photo) async -> UIImage? {
        return await imageCache.image(for: photo.url)
    }
    
    func refresh() async {
        await loadPhotos()
    }
    
    func clearCache() {
        Task {
            await imageCache.clearCache()
        }
    }
}
