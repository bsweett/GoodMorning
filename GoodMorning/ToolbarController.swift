//
//  ToolbarController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-23.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import UIKit

class ToolbarController: UIViewController {
    
    
    @IBOutlet var settingsButton: UIBarButtonItem!
    
    // Change button symbol and func based on current embeded view container
    @IBOutlet var rightButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var pageController = storyboard.instantiateViewControllerWithIdentifier("Pager") as UIViewController
        self.displayContentController(pageController)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayContentController(content: UIViewController) {
        
        self.addChildViewController(content)
        content.didMoveToParentViewController(self)
        self.view.insertSubview(content.view, atIndex: 1)
        
    }
    
    @IBAction func settingsButtonPushed() {
        // only supported in iOS8
        
        if( ios8() ) {
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
        } else {
             //TODO: need a view for iOS7 and below
            performSegueWithIdentifier("OldSettingsView", sender: self)
            //send as modal and call dismissViewController when finished
        }
    
    }
    
    @IBAction func rightBarButtonPushed() {
        
    }

}
