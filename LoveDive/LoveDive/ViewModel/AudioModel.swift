//
//  AudioManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/27.
//

import AVKit
import Foundation

class AudioModel: NSObject, ObservableObject, AVAudioPlayerDelegate {

  var player: AVAudioPlayer?

  func startPlayer(track: String) {
    guard let url = Bundle.main.url(forResource: track, withExtension: "m4a") else {
      print("Resources not found: \(track)")
      return
    }

    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default) // play sound even when silent mode
      try AVAudioSession.sharedInstance().setActive(true) // play sound even when interrupted
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

  func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully flag: Bool) {
    if flag {
      startPlayer(track: "Beach Ambience")
    }
  }

}
