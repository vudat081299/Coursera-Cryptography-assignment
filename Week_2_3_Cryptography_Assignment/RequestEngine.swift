//
//  RequestEngine.swift
//  Week_2_3_Cryptography_Assignment
//
//  Created by Dat Vu on 06/01/2023.
//

import Foundation

enum ResourcesRequest<ResolveType> {
    case failure(ResolveType)
}

var basedURL: String = "http://crypto-class.appspot.com/po"
var urlComponents: URLComponents!
struct ResourceRequest<PostType, ResolveType> where PostType: Codable, ResolveType: Codable {
//    let resourceURL: URL
    init(resourcePath: String) {
        guard let resourceURL = URL(string: basedURL) else {
            fatalError()
        }
        urlComponents = URLComponents(string: basedURL)!
        urlComponents.queryItems = [
             URLQueryItem(name: "er", value: resourcePath)
        ]
//        let newResourcePath = "?er=" + resourcePath
        //        f20bdba6ff29eed7b046d1df9fb7000058b1ffb4210a580f748b4ac714c001bd4a61044426fb515dad3f21f18aa577c0bdf302936266926ff37dbf7035d5eeb4
        //        f20bdba6ff29eed7b046d1df9fb7000058b1ffb4210a580f748b4ac714c001bd4a61144426fb515dad3f21f18aa577c0bdf302936266926ff37dbf7035d5eeb4
//        self.resourceURL = resourceURL.appendingPathComponent(newResourcePath)
    }
    
    
    
    // MARK: - Get.
    func get(completion: @escaping (ResourcesRequest<Int>) -> Void) {
        let urlRequest = URLRequest(url: urlComponents.url!)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            completion(.failure(httpResponse.statusCode))
        }
        dataTask.resume()
    }
}
