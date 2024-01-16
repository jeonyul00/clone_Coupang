//
//  NetworkService.swift
//  coupang
//
//  Created by 전율 on 2024/01/16.
//

import Foundation

class NetWorkService {
    static let shared:NetWorkService = NetWorkService()
    
    func getHomeData() async throws -> HomeResponse {
        let urlString = "https://my-json-server.typicode.com/JeaSungLEE/JsonAPIFastCampus/db"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, reponse) = try await URLSession.shared.data(from: url)
        guard let httpResponse = reponse as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw URLError(.badServerResponse) }
        let decodeData = try JSONDecoder().decode(HomeResponse.self, from: data)
        return decodeData
    }
}
