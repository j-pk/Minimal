//
//  PlayerView.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/2/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    var player: AVPlayer? {
        get {
            playerLayer.videoGravity = .resizeAspect
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
            if newValue == nil {
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(playAndLoop), name: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(stalled), name: .AVPlayerItemPlaybackStalled, object: self.player?.currentItem)
    }
    
    @objc func playAndLoop() {
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    //TODO: Handle stalls with Retry attempts
    @objc private func stalled() {
        if let player = self.player {
            if player.currentTime() > kCMTimeZero && player.currentTime() != player.currentItem?.duration {
                player.pause()
            }
        }
    }
    
    func play() {
        addObservers()
        player?.play()
        player?.isMuted = true
    }
    
    func pause() {
        player?.pause()
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
