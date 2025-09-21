import Foundation

struct Photo: Codable, Identifiable {
    let id: Int
    let title: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, url
    }
}

struct PhotoResponse: Codable {
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case photos
    }
}