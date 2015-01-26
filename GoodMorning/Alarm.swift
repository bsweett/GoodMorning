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
    var timeString: String
    var enabled: Bool
    var notificationId: Int
    
    // when we install the app create 4 new tasks of type alarms and send them with the install request
    // we can display alarms in the task list but dont allow them to be editable (IE send them to the alarm view when they tap on them)
    // if an alarm is deleted hide the view in the alarms
    // cannot hold more than 4 alarms at the moment
    init(task: Task) {
        self.task = task
        //self.player = AVAudioplayer()
        self.playing = false
        self.timeToSetOff = task.nextAlertDate
        self.timeString = task.alertTime
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