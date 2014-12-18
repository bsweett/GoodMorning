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
    //var player: AVAudioplayer
    var timeToSetOff: NSDate
    var label: String
    var enabled: Bool
    var notificationId: Int
    
    init(task: Task) {
        self.task = task
        //self.player = AVAudioplayer()
        self.playing = false
        self.timeToSetOff = task.nextAlertDate
        self.label = task.title
        self.enabled = true
        self.notificationId = 0
    }
    
    func play() {
        
        if playing {
          return
        }
        
    }
    
    func stop() {
        
    }
   
}