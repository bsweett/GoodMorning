//
//  Alarm.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import AVFoundation

class Alarm : NSObject {
    
    var playing: Bool
    var task: Task
    var player: AVAudioplayer
    
    init(task: Task) {
        self.task = task
        self.player = AVAudioplayer()
        self.playing = false
    }
    
    func play() {
        
        if playing {
          return
        }
        
    }
    
    func stop() {
        
    }
   
}