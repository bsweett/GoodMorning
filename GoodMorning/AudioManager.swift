//
//  AudioManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-03.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit
import AVFoundation

class AudioManager: NSObject {
   
    var gmSoundFileNames: [String] = ["", "", "", "", "", "", ""]
    var audioPlayer = AVAudioPlayer()
    
    func playAlertSoundWithName(name: String) {
        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(name, ofType: "wav")!)
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
}
