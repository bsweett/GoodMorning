//
//  AlarmDetailViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit

class AlarmDetailViewController : UIViewController {
    
    //var alarm: Alarm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.alarm = Alarm(nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     override func viewDidAppear(animated: Bool) {
        
        // TODO: The app should offer an offline mode via this alert and should check if offline mode is enabled
        // for every page view. otherwise keep displaying the dialog each time the page appears offline
        // offline mode should be stored in app settings so they can toggle it
        
        if(!Reachability.isConnectedToNetwork()) {
            /*
            alert.title = "Network Connection"
            alert.message = "You don't appear to be connected to the Internet. Please check your connection."
            alert.show()*/
        }
    }
    
}