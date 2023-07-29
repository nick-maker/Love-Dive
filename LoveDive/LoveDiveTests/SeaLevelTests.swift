//
//  LoveDiveTests.swift
//  LoveDiveTests
//
//  Created by Nick Liu on 2023/7/21.
//

import Alamofire
import XCTest
@testable import LoveDive

// MARK: - SeaLevelTests

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
      case .success:
        isSuccess = true
      case .failure:
        isSuccess = false
      }
      XCTAssertEqual(isSuccess, true)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 3)
  }

}

// MARK: - MockNetworkService

class MockNetworkService: NetworkProtocol {

  var mockResponse: Result<TideData, Error> = .success(decodeJSON())

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

  func request(
    _: URLConvertible,
    method _: HTTPMethod,
    parameters _: Parameters?,
    headers _: HTTPHeaders?,
    completion: @escaping (Result<LoveDive.TideData, Error>) -> Void)
  {
    completion(mockResponse)
  }

}
