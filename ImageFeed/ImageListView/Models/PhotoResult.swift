//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by ulyana on 28.01.25.
//

import Foundation

enum ParseError: Error {
    case createdAt
}

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let description: String?
    let urlsResult: UrlsResult
    let likedByUser: Bool
    
    enum CodingKeys: CodingKey {
        case id, width, height, createdAt, description, urlsResult, likedByUser
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        
        let createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        if let createdAt = createdAt {
            let currentDate = DateFormatter()
            currentDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            let createdAtValue = currentDate.date(from: createdAt)
            
            guard let createdAtValue = createdAtValue else {
                throw ParseError.createdAt
            }
            self.createdAt = createdAtValue
        }
        
        description = try container.decodeIfPresent(String.self, forKey: .description)

        urlsResult = try container.decode(UrlsResult.self, forKey: .urlsResult)
        likedByUser = try container.decode(Bool.self, forKey: .likedByUser)
    }
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}

