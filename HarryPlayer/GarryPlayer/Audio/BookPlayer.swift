//
//  BookPlayer.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import Foundation
import AVFoundation

protocol BookPlayer: Equatable {
    
    var filesAmount: Int { get }
    var isPlaying: Bool { get }
    
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    
    func play()
}

class AVBookPlayer: NSObject, BookPlayer {
    
    var filesAmount: Int { fileNames.count }
    var isPlaying: Bool { player?.isPlaying ?? false }
    var duration: TimeInterval { player?.duration ?? 0.0 }
    var currentTime: TimeInterval { player?.currentTime ?? 0.0 }
    
    private var player: AVAudioPlayer?
    private let fileNames: [String]
    
    override init() {
        
        fileNames = AudioFilesNamesProvider().get
        
        if let fileName = fileNames.first,
           let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            player = try? AVAudioPlayer(contentsOf: url)
        }
        
        super.init()
    }
    
    // Play or pause audio
    func play() {
        
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AVBookPlayer: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // play next chapter
    }
}
