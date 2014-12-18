//
//  TextToSpeech.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import AVFoundation

class TextToSpeech: NSObject {
    
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    var enabled = false
    
    init(enabled: Bool) {
        self.enabled = enabled
    }
    
    func speak(words: String) {
        
        if enabled == true {
            myUtterance = AVSpeechUtterance(string: words)
            myUtterance.rate = 0.1
            synth.speakUtterance(myUtterance)
        }
        
    }
}


