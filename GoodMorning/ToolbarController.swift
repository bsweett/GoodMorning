//
//  ToolbarController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-23.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import UIKit

class ToolbarController: UIViewController {
    
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

}
