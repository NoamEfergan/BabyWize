//
//  SharingAccount.swift
//  BabyWize
//
//  Created by Noam Efergan on 22/11/2022.
//

import Foundation

struct SharingAccount: Hashable, Identifiable, Codable {
    let id: String
    let email: String
    
    init(id: String, email: String) {
        self.id = id
        self.email = email
    }
    
    enum CodingKeys: CodingKey {
        case id
        case email
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.email, forKey: .email)
    }
}
