//
//  BreatheView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/26.
//

import SwiftUI

struct BreatheContentView: View {
  @EnvironmentObject var breatheModel: BreatheModel
  @EnvironmentObject var audioModel: AudioModel
    var body: some View {
        BreatheView()
        .environmentObject(breatheModel)
        .environmentObject(audioModel)
    }
}

struct BreatheView_Previews: PreviewProvider {
    static var previews: some View {
        BreatheContentView()
    }
}
