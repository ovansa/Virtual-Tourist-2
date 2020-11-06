//
//  ImageDownloadManager.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 30/10/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit
import RealmSwift

typealias ImageList = [String]

struct ImageDownloadManager {
    let realm = try! Realm()
    static let imageURL = "https://www.flickr.com/services/rest/"
    
    //MARK: - Methods to fetch and parse the list of image URLs
    
    static func fetchImageURLList(latitude: Double, longitude: Double, urlList: @escaping(ImageList?, Error?) -> Void) {
        if var imageListUrl = URLComponents(string: imageURL) {
            imageListUrl.queryItems = [
                URLQueryItem(name: "method", value: "flickr.photos.search"),
                URLQueryItem(name: "api_key", value: "d2f8674bbf96cb652663f7eeba742af0"),
                URLQueryItem(name: "privacy_filter", value: "1"),
                URLQueryItem(name: "lat", value: String(latitude)),
                URLQueryItem(name: "lon", value: String(longitude)),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "nojsoncallback", value: "1")
            ]
            
            let request = URLRequest(url: imageListUrl.url!)
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    print("Fetching image list failed: \(error!)")
                    urlList(nil, error)
                }
                
                if let safeData = data {
                    if let imageURLList = self.parseImageURLS(safeData) {
                        urlList(imageURLList, nil)
                    }
                }
            }
            task.resume()
        }
    }
    
    static func parseImageURLS(_ imageURLSData: Data) -> ImageList? {
        let decoder = JSONDecoder()
        var imageList = ImageList()
        
        do {
            let decodedData = try decoder.decode(ImageURLS.self, from: imageURLSData)
            
            for photo in decodedData.photos.photo {
                let id = photo.id
                let farm = photo.farm
                let owner = photo.owner
                let secret = photo.secret
                let server = photo.server
                let title = photo.title
                
                let image = ImageURLModel(id: id, farm: farm, owner: owner, secret: secret, server: server, title: title)
                imageList.append(image.imageURL)
            }
            
            return imageList
        } catch {
            print("Error parsing JSON: \(error)")
            return nil
        }
    }
    
    //MARK: - Download, Save, and Return directory strings of Images
//    
//    
////    func fetchSavedImageURL(from urls: [ImageModel]) -> ImageList {
////        let semaphore = DispatchSemaphore(value: 0)
////        var imageList = ImageList()
////
////        DispatchQueue.main.async {
////            for imageUrl in urls {
////                self.downloadImage(url: imageUrl.imageURL) { (image) in
////                    if let directoryUrl = self.saveDownloadedImageToDirectory(imageName: imageUrl.id, image: image) {
////                        imageList.append(directoryUrl)
////                        semaphore.signal()
////                    }
////                }
////            }
////        }
////        semaphore.wait()
////        return imageList
////    }
//
//    
//    func fetchSavedImageURL(from urls: [ImageModel], listOFImages: @escaping (ImageList) -> Void) {
//        let group = DispatchGroup()
//        var imageList = ImageList()
//        
//        if !urls.isEmpty {
//            if urls.count >= 20 {
//                for imageUrl in urls[0..<20] {
//                    group.enter()
//                    fetchImage(url: imageUrl.imageURL) { (image) in
//                        if let directoryUrl = self.saveDownloadedImageToDirectory(imageName: imageUrl.id, image: image) {
//                            imageList.append(directoryUrl)
//                        }
//                        group.leave()
//                    }
//                }
//            }
//        } else {
//            print("There is no url")
//        }
//        
//        group.notify(queue: .main) {
//            listOFImages(imageList)
//        }
//    }
//    
//    func fetchImage(url: String, singleImage: @escaping(UIImage) -> Void) {
//        if let urlString = URL(string: url) {
//            let session = URLSession(configuration: .default)
//            
//            let task = session.dataTask(with: urlString) { (data, response, error) in
//                if error != nil {
//                    print("Error fetching image data: \(String(describing: error))")
//                }
//                
//                if let safeImage = data {
//                    let image = UIImage(data: safeImage)
//                    DispatchQueue.main.async {
//                        singleImage(image!)
//                    }
//                }
//            }
//            task.resume()
//        }
//    }
//    
//    
//    
//    // Fetch list of images
//    // Save image urls to
//    
//    func saveDownloadedImageToDirectory(imageName: String, image: UIImage) -> String? {
//        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let name = String("\(imageName).jpg")
//        let documentUrl = document.appendingPathComponent(name)
//        
//        if let safeImage = image.jpegData(compressionQuality: 1) {
//            do {
//                try safeImage.write(to: documentUrl)
//            } catch {
//                print("Error writing image to disk: \(error)")
//            }
//        }
//        return documentUrl.absoluteString
//    }
}

struct ImageURLModel {
    let id: String
    let farm: Int
    let owner: String
    let secret: String
    let server: String
    let title: String
    
    var imageURL: String {
        return "https://farm\(String(farm)).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
}

//struct ImageModel {
//    let id: String
//    let imageURL: String
//}
