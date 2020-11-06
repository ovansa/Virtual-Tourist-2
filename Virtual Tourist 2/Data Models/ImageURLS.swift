//
//  ImageList.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 30/10/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import Foundation

struct ImageURLS: Decodable {
    let photos: AllImages
}

struct AllImages: Decodable {
    let photo: [SingleImage]
}

struct SingleImage: Decodable {
    let id: String
    let farm: Int
    let owner: String
    let secret: String
    let server: String
    let title: String
}
