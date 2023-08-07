//
//  HealthKitManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/19.
//

import Combine
import Foundation
import HealthKit

// MARK: - HealthKitManger

class HealthKitManager {

  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  static let shared = HealthKitManager()

  var divingLogsPublisher: AnyPublisher<[DivingLog], Never> {
    divingLogsSubject.eraseToAnyPublisher()
  }

  var tempsPublisher: AnyPublisher<[Temperature], Never> {
    tempsSubject.eraseToAnyPublisher()
  }

  func requestHealthKitPermissions() {
    // Specify the data types you want to access
    guard
      let depthType = HKObjectType.quantityType(forIdentifier: .underwaterDepth),
      let temperatureType = HKObjectType.quantityType(forIdentifier: .waterTemperature) else
    {
      return
    }

    let readDataTypes: Set<HKObjectType> = [depthType, temperatureType]

    // Request access
    healthStore.requestAuthorization(toShare: nil, read: readDataTypes) { success, error in
      if success {
        // Permissions granted
        self.readDive()
      } else {
        if let error {
          print("Error requesting HealthKit authorization: \(error)")
        } else {
          print("HealthKit authorization not granted")
        }
      }
    }
  }

  // MARK: Private

//  private var divingLogs: [DivingLog] = []
//  private var temps: [Temperature] = []
  private let healthStore = HKHealthStore()

  private var divingLogsSubject = CurrentValueSubject<[DivingLog], Never>([])
  private var tempsSubject = CurrentValueSubject<[Temperature], Never>([])

  private func readDive() {
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      readUnderwaterDepths(healthStore: healthStore) { diveQuery in
//        let sortedDives = diveQuery.sorted(by: { $0.startTime.compare($1.startTime) == .orderedDescending })
//        DispatchQueue.main.async {
          self.divingLogsSubject.send(diveQuery)
//        }
      }
      readWaterTemps(healthStore: healthStore) { tempSamples in
//        DispatchQueue.main.async {
          self.tempsSubject.send(tempSamples)
//        }
      }
    }
  }

  private func readUnderwaterDepths(healthStore: HKHealthStore, completion: @escaping ([DivingLog]) -> Void) {
    var diveList: [DivingLog] = []
    var lastSessionEnd: Date? = nil
    var currentLog: DivingLog?

    guard let underwaterDepthType = HKQuantityType.quantityType(forIdentifier: .underwaterDepth) else {
      completion([])
      return
    }

    let query = HKQuantitySeriesSampleQuery(quantityType: underwaterDepthType, predicate: nil) {
      _, result, dates, _, _, _ in

      guard
        let result,
        let diveDates = dates else
      {
        completion([])
        return
      }
      var diffSeconds: Double
      if let lastSessionEnd {
        diffSeconds = diveDates.start.timeIntervalSince(lastSessionEnd)
      } else {
        diffSeconds = 99
      }

      if diffSeconds > 60 {
        if let log = currentLog {
          diveList.append(log)
        }

        let newLog = DivingLog(startTime: diveDates.start, session: [])
        currentLog = newLog
      }

      lastSessionEnd = diveDates.end

      let entry = DivingEntry(start: diveDates.start, depth: result.doubleValue(for: HKUnit.meter()), animate: false)
      currentLog?.session.append(entry)

      completion(diveList)
    }

    healthStore.execute(query)
  }

  private func readWaterTemps(healthStore: HKHealthStore, completion: @escaping ([Temperature]) -> Void) {
    var temps: [Temperature] = []

    guard let waterTempType = HKQuantityType.quantityType(forIdentifier: .waterTemperature) else { return }

    let query = HKQuantitySeriesSampleQuery(quantityType: waterTempType, predicate: nil) {
      _, result, dates, _, _, _ in

      guard let result else {
        print("Nil Result to temperature query")
        completion([])
        return
      }

      if let sampleDate = dates {
        temps
          .append(Temperature(
            start: sampleDate.start,
            end: sampleDate.end ,
            temp: result.doubleValue(for: HKUnit.degreeCelsius())))
      }
      completion(temps)
    }

    healthStore.execute(query)
  }

}
