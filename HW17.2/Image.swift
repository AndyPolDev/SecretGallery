import Foundation
import UIKit

class Image: Codable {
    
    var image: String?
    var isLike: Bool
    var comment: String
    
    init(image: String?, isLike: Bool, comment: String) {
        self.image = image
        self.isLike = isLike
        self.comment = comment
    }
    
    public enum CodingKeys: String, CodingKey {
        case image, isLike, comment
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.isLike = try container.decode(Bool.self, forKey: .isLike)
        self.comment = try container.decode(String.self, forKey: .comment)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.image, forKey: .image)
        try container.encode(self.isLike, forKey: .isLike)
        try container.encode(self.comment, forKey: .comment)
    }
    
}

