//
//  TextToSpeech.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import AVFoundation

// TEMP: This will do until I can find a better Text-To-Speech for swift
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
            
            // TODO: Can change language
            //myUtterance.voice = AVSpeechSynthesisVoice.language("")
            myUtterance.rate = 0.1
            synth.speakUtterance(myUtterance)
        }
        
    }
    
    func speakWithPostAndPreDelay(words: String, preLength: Double, postLength: Double) {
        if enabled == true {
            myUtterance = AVSpeechUtterance(string: words)
            myUtterance.postUtteranceDelay = postLength
            myUtterance.preUtteranceDelay = preLength
            myUtterance.rate = 0.1
            synth.speakUtterance(myUtterance)
        }
    }
    
    func speakStringsWithPause(words1: String, words2: String, pauseLength: Double) {
        self.speakWithPostAndPreDelay(words1, preLength: 0, postLength: pauseLength/2)
        self.speakWithPostAndPreDelay(words2, preLength: pauseLength/2, postLength: 0)
    }
}


