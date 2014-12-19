//
//  InstallViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-18.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit

class InstallViewController : UIViewController {

    let deviceId: String = UIDevice.currentDevice().identifierForVendor.UUIDString
    let userId: String = NSUUID().UUIDString
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}