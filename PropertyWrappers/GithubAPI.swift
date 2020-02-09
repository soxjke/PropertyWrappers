//
//  GithubAPI.swift
//  PropertyWrappers
//
//  Created by Petro Korienev on 2/9/20.
//  Copyright © 2020 PetroKorienev. All rights reserved.
//

import Foundation

class GithubAPI {
    struct Response: Codable {
        let total_count: Int
        let items: [Model]; struct Model: Codable {
            let full_name: String
            let stargazers_count: Int
        }
    }
    static func search(term: String, completion: @escaping (Result<[Response.Model], Error>) -> ()) {
        if let searchURL = URL(string: "https://api.github.com/search/repositories?q=\(term)") {
            let task = URLSession.shared.dataTask(with: searchURL) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                } else if (response as? HTTPURLResponse)?.statusCode == 403 {
                    completion(.failure(NSError(domain: "GithubAPI", code: -1, userInfo: ["NSErrorLocalizedDescription":"Rate Limit Exceeded"])))
                } else {
                    guard let data = data else {
                        completion(.failure(NSError(domain: "GithubAPI", code: -2, userInfo: ["NSErrorLocalizedDescription":"Can't load data"])))
                        return
                    }
                    do {
                        let response = try JSONDecoder().decode(Response.self, from: data)
                        completion(.success(response.items))
                    } catch(let error) {
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
        }
    }
}
