//
//  ShareView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/25.
//

import SwiftUI

// MARK: - ShareView

struct ShareView: View {

  var data: [DivingEntry]
  var maxDepth = 0.0
  var temp = 0.0
  @State var generatedImage: Image?

  var body: some View {
    ZStack {
      ChartView(data: data, maxDepth: maxDepth, temp: temp)
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        generateSnapshot()
      }
    }
    .navigationBarTitle("Diving Log", displayMode: .large)
    .navigationBarItems(
      trailing:
        ShareLink(
          item: generatedImage ?? Image(systemName: ""),
          preview: SharePreview("Diving Log", image: generatedImage ?? Image(systemName: ""))))
  }

  @MainActor
  func generateSnapshot() {
    let renderer = ImageRenderer(content: ChartView(data: data, maxDepth: maxDepth, temp: temp))
    if let image = renderer.uiImage {
          print("Image generated successfully")
          generatedImage = Image(uiImage: image)
        } else {
          print("Failed to generate image")
        }
  }


}

// MARK: - ShareView_Previews

//struct ShareView_Previews: PreviewProvider {
//  static var previews: some View {
//    ShareView(data: [
//      DivingEntry(
//        id: "CF4CF548-F700-4661-93BD-0409F768255D",
//        time: Date(timeIntervalSince1970: 1641876992),
//        depth: 3.163539853270894),
//      DivingEntry(
//        id: "788196D1-EF47-4B50-98BE-D738E1D3C51A",
//        time: Date(timeIntervalSince1970: 1641876995),
//        depth: 4.850410152151905),
//      DivingEntry(
//        id: "B0976BD3-13D3-4034-9F5A-675CF0BE53A7",
//        time: Date(timeIntervalSince1970: 1641876998),
//        depth: 6.67847192904102),
//      DivingEntry(
//        id: "A56ECAD6-A4F1-476C-A900-3D059E3CD78A",
//        time: Date(timeIntervalSince1970: 1641877000),
//        depth: 8.540038785210685),
//      DivingEntry(
//        id: "988AB2C1-0C6F-4990-B24E-78B2C8FA4950",
//        time: Date(timeIntervalSince1970: 1641877003),
//        depth: 10.406927951597517),
//      DivingEntry(
//        id: "D6B1FE3C-8C5A-49C3-A650-1402D8F15FCD",
//        time: Date(timeIntervalSince1970: 1641877006),
//        depth: 12.534566080449434),
//      DivingEntry(
//        id: "45E1849A-3D96-4DEB-9C97-9F89B0B5881A",
//        time: Date(timeIntervalSince1970: 1641877008),
//        depth: 14.450256056855576),
//      DivingEntry(
//        id: "E06E167F-5210-4E31-A7D2-C4F4A843BAC1",
//        time: Date(timeIntervalSince1970: 1641877011),
//        depth: 16.2924923555383),
//      DivingEntry(
//        id: "DEB35F8C-5BFD-4B9A-8DB0-371302402C59",
//        time: Date(timeIntervalSince1970: 1641877014),
//        depth: 18.01839750570824),
//      DivingEntry(
//        id: "3259AE18-B2DF-406F-B240-5FBFF98A22B5",
//        time: Date(timeIntervalSince1970: 1641877016),
//        depth: 19.708213456933578),
//      DivingEntry(
//        id: "9B01D403-0B9F-4792-A82F-E5ADC65E14C9",
//        time: Date(timeIntervalSince1970: 1641877019),
//        depth: 21.434338272529505),
//      DivingEntry(
//        id: "898E7330-F9BD-4AD3-B37E-3F2E786D58B1",
//        time: Date(timeIntervalSince1970: 1641877022),
//        depth: 23.196964159743764),
//      DivingEntry(
//        id: "7607A448-DB28-42A6-98ED-C10DAF74A7F1",
//        time: Date(timeIntervalSince1970: 1641877024),
//        depth: 24.932299668687715),
//      DivingEntry(
//        id: "D06F457A-8B31-45F4-8A1D-594DC25538A5",
//        time: Date(timeIntervalSince1970: 1641877027),
//        depth: 26.655901382793477),
//      DivingEntry(
//        id: "8900E782-4FCD-4915-9C88-B1B29F892D37",
//        time: Date(timeIntervalSince1970: 1641877030),
//        depth: 28.32607253293636),
//      DivingEntry(
//        id: "6275A3E2-C732-406E-A6E5-D2D3DF05CA9C",
//        time: Date(timeIntervalSince1970: 1641877032),
//        depth: 29.216263620843836),
//      DivingEntry(
//        id: "4CCDC992-553A-4EA0-B6B5-B1D04FD242C4",
//        time: Date(timeIntervalSince1970: 1641877035),
//        depth: 28.557694470097182),
//      DivingEntry(
//        id: "EE4380E7-38A1-40BF-93DC-32F654E612B4",
//        time: Date(timeIntervalSince1970: 1641877038),
//        depth: 27.584906131109545),
//      DivingEntry(
//        id: "679B5BBC-A164-4234-8C0B-B301C099C500",
//        time: Date(timeIntervalSince1970: 1641877040),
//        depth: 25.728303103385468),
//      DivingEntry(
//        id: "8F7D3DD3-CD60-4292-8919-8ACF8ADA8BB4",
//        time: Date(timeIntervalSince1970: 1641877043),
//        depth: 22.756031580703368),
//      DivingEntry(
//        id: "E7D73801-755F-4493-9FDD-C16F4CF44219",
//        time: Date(timeIntervalSince1970: 1641877046),
//        depth: 19.795069776550953),
//      DivingEntry(
//        id: "E1FC5D28-FC7D-4B7F-861A-A4997226C887",
//        time: Date(timeIntervalSince1970: 1641877048),
//        depth: 16.9247016551664),
//      DivingEntry(
//        id: "2CD286A3-64DB-49F8-BD74-6C10ED58B22D",
//        time: Date(timeIntervalSince1970: 1641877051),
//        depth: 14.190754916046448),
//      DivingEntry(
//        id: "BD2CF1FC-8421-4278-9F44-F2618A029EBC",
//        time: Date(timeIntervalSince1970: 1641877054),
//        depth: 11.898897050362025),
//      DivingEntry(
//        id: "97D2CAF9-DFDE-4718-B4BD-6106C48196E0",
//        time: Date(timeIntervalSince1970: 1641877056),
//        depth: 9.687148419717582),
//      DivingEntry(
//        id: "D473EDBE-70BC-4A1C-912A-9821B4CE0364",
//        time: Date(timeIntervalSince1970: 1641877059),
//        depth: 7.321031436414454),
//      DivingEntry(
//        id: "8F7F7B13-A160-4D95-ACF7-03F784B135AC",
//        time: Date(timeIntervalSince1970: 1641877062),
//        depth: 4.702942954959675),
//      DivingEntry(
//        id: "EC621261-1865-4607-BBC9-7B1399AFCFDC",
//        time: Date(timeIntervalSince1970: 1641877064),
//        depth: 2.1503216349938676),
//    ])
//  }
//}
