//
//  Menu.swift
//  Assignment
//
//

struct MenuList: Codable {
    var menus:[Menu]
    var category: String
    var categoryID: String
    var categoryImage: String
}

struct Menu: Codable {
    var name: String?
    var image: String?

    enum Keys: CodingKey {
        case name
        case image
    }
        
   init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: Keys.self)
       self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Niil"
       self.image = try container.decodeIfPresent(String.self, forKey: .image) ?? "Nil"
   }
}

