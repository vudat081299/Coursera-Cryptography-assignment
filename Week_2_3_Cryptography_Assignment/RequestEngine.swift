//
//  RequestEngine.swift
//  Week_2_3_Cryptography_Assignment
//
//  Created by Dat Vu on 06/01/2023.
//

import Foundation

enum ResourcesRequest {
    case failure(Int)
}

var basedURL: String = "http://crypto-class.appspot.com/po"
struct ResourceRequest {
    var urlComponents: URLComponents
    init(resourcePath: String) {
        urlComponents = URLComponents(string: basedURL)!
        urlComponents.queryItems = [
             URLQueryItem(name: "er", value: resourcePath)
        ]
//        f20bdba6ff29eed7b046d1df9fb7000058b1ffb4210a580f748b4ac714c001bd4a61044426fb515dad3f21f18aa577c0bdf302936266926ff37dbf7035d5eeb4
//        f20bdba6ff29eed7b046d1df9fb7000058b1ffb4210a580f748b4ac714c001bd4a61144426fb515dad3f21f18aa577c0bdf302936266926ff37dbf7035d5eeb4
    }
    
    
    
    // MARK: - Get.
    func get(completion: @escaping (ResourcesRequest) -> Void) {
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
