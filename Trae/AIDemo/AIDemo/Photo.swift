import Foundation

struct Photo: Codable, Identifiable {
    let id: Int
    let title: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, url
    }
}

// TODO: 代码生成能力中，增加了PhotoResponse却没有使用
struct PhotoResponse: Codable {
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case photos
    }
}
