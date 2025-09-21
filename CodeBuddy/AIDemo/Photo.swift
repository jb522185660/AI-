import Foundation

struct Photo: Codable, Identifiable {
    let id: Int
    let title: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
    }
}

struct MockPhotoService {
    static func mockPhotos() -> [Photo] {
        return [
            Photo(id: 1, title: "美丽的风景", url: "https://picsum.photos/200/300?random=1"),
            Photo(id: 2, title: "城市夜景", url: "https://picsum.photos/200/300?random=2"),
            Photo(id: 3, title: "海滩日落", url: "https://picsum.photos/200/300?random=3"),
            Photo(id: 4, title: "山脉云雾", url: "https://picsum.photos/200/300?random=4"),
            Photo(id: 5, title: "森林小路", url: "https://picsum.photos/200/300?random=5"),
            Photo(id: 6, title: "现代建筑", url: "https://picsum.photos/200/300?random=6"),
            Photo(id: 7, title: "古典艺术", url: "https://picsum.photos/200/300?random=7"),
            Photo(id: 8, title: "科技未来", url: "https://picsum.photos/200/300?random=8")
        ]
    }
}