//
//  MusicPlayer.swift
//  UncrossChicky
//
//  Created by alex on 3/15/25.
//

import Foundation
import AVFoundation
import SwiftUI

class MusicPlayer {
    @AppStorage("isSoundEffectsOn") private var isSoundEffectsOn: Bool = false
    static let shared = MusicPlayer()
    private var audioPlayer: AVAudioPlayer?
    private var soundEffectPlayer: AVAudioPlayer?

    func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "music", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Вечный цикл
            audioPlayer?.play()
        } catch {
            print("Не удалось воспроизвести музыку: \(error.localizedDescription)")
        }
    }

    func stopBackgroundMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    func playSoundEffect(name: String) {
        if isSoundEffectsOn {
            guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
            
            do {
                soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
                soundEffectPlayer?.numberOfLoops = 0 // Воспроизвести один раз
                soundEffectPlayer?.play()
            } catch {
                print("Не удалось воспроизвести звук: \(error.localizedDescription)")
            }
        }
    }
}
