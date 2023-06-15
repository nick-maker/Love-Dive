//
//  NetworkManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/15.
//

import Alamofire
import Foundation

class NetworkManager {

  static let shared = NetworkManager()

  func fetch<T: Decodable>(url: String, completion: @escaping (Result<T, Error>) -> Void) {
    AF.request(url, method: .get).responseDecodable(of: T.self) { response in
      switch response.result {
      case .success(let data):
        completion(.success(data))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

}
