//
//  AudioManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/27.
//

import Foundation
import AVKit

class AudioModel: NSObject, ObservableObject, AVAudioPlayerDelegate {

  var player: AVAudioPlayer?

  func startPlayer(track: String) {
    guard let url = Bundle.main.url(forResource: track, withExtension: "wav") else {
      print("Resources not found: \(track)")
      return
    }

    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
      player = try AVAudioPlayer(contentsOf: url)
      player?.delegate = self
      player?.play()
    } catch {
      print("Failed to initialize player: \(error)")
    }
  }

  func stopPlayer() {
    player?.stop()
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    if flag {
      startPlayer(track: "Artlist Original - Tel Aviv Ambiences - Beach Ambience Waves Lapping Windy")
    }
  }

}
