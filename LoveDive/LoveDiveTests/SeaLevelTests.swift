//
//  LoveDiveTests.swift
//  LoveDiveTests
//
//  Created by Nick Liu on 2023/7/21.
//

import XCTest
@testable import LoveDive
import Alamofire
// swiftlint:disable implicitly_unwrapped_optional
final class SeaLevelTests: XCTestCase {

  var sut: SeaLevelModel!

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  func testSeaLevelAPI() {
    sut = SeaLevelModel(networkRequest: MockNetworkService())

    let expectation = expectation(description: "Sea level request")

    sut.getFromAPI(lat: 22.3348440, lng: 120.3776006, key: "seaLevel22.3348440,120.3776006") { result in

      let isSuccess: Bool

      switch result {
      case .success(_):
        isSuccess = true
      case .failure(_):
        isSuccess = false
      }
      XCTAssertEqual(isSuccess, true)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 3)
  }

}

class MockNetworkService: NetworkProtocol {

  func request(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders?, completion: @escaping (Result<LoveDive.TideData, Error>) -> Void) {
    completion(mockResponse)
  }

  static func decodeJSON() -> TideData {
    guard let url = Bundle.main.url(forResource: "SeaLevel", withExtension: "json") else {
      return TideData(data: [])
    }
    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      let decodedData = try decoder.decode(TideData.self, from: data)
      return decodedData
    } catch {
      return TideData(data: [])
    }
  }

  var mockResponse: Result<TideData, Error> = .success(decodeJSON())

}
