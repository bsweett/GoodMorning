//
//  NewsPopoverViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-15.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class NewsPopoverViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var urlFeild: UITextField!
    @IBOutlet weak var urlCheckLabel: UILabel!
    @IBOutlet weak var urlCheckImageView: UIImageView!
    @IBOutlet weak var typePicker: UIPickerView!
    
    var pickerData: [String]!
    
    var displayFeed: RSSFeed!
    var newsManager: NewsManager!
    var rootViewController: NewsViewController!
    var previewVC: NewsPreviewViewController!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayFeed = RSSFeed(id: "", title: "", creation: NSDate(), lastActiveDate: NSDate(), type: RSSType.NEWS, description: "", language: "", link: "", rssLink: "")
        self.newsManager = NewsManager()
        
        self.pickerData = RSSType.displayValues
        self.typePicker.dataSource = self
        self.typePicker.delegate = self
        self.urlFeild.delegate = self
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        var backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.typePicker.selectRow(0, inComponent: 0, animated: true)
        
        //Note: This is just for testing
        self.urlFeild.text = "http://feeds.feedburner.com/businessinsider"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name:"NetworkError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InternalServerError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInvalidRSS:", name:"InvalidRSSURL", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedValidRSS:", name:"ShowRSSPreview", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func receivedNetworkError(notification: NSNotification) {
        /*SCLAlertView().showError("Network Error",
        subTitle: "Oops something went wrong",
        closeButtonTitle: "Dismiss")*/
    }
    
    func receivedInternalServerError(notification: NSNotification) {
        //stopLoading()
        let reason = getUserInfoValueForKey(notification.userInfo, "reason")
        let message = getUserInfoValueForKey(notification.userInfo, "message")
        SCLAlertView().showWarning("Internal Server Error",
            subTitle:  reason + " - " + message, closeButtonTitle: "Dismiss")
    }
    
    // TODO: Both of these should show the preview only change what is shown
    // ie error something was wrong with the feed you entered
    // or preview of the channel info
    func receivedInvalidRSS(notification: NSNotification) {
        
        if(self.previewVC == nil) {
            self.previewVC = NewsPreviewViewController(nibName: "NewsPreviewViewController", bundle: nil)
        }
        
        self.previewVC.setRSSFeed(nil)
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
    func receivedValidRSS(notification: NSNotification) {
        let userInfo: Dictionary<String, RSSFeed> = notification.userInfo as Dictionary<String, RSSFeed>
        
        if(self.previewVC == nil) {
            self.previewVC = NewsPreviewViewController(nibName: "NewsPreviewViewController", bundle: nil)
        }
        self.previewVC.delegate = self.rootViewController
        self.previewVC.setRSSFeed(userInfo["feed"])
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    // TODO
    
    
    //TODO: Get check and uncheck image asset
    func setValidLabelAndImage(valid: Bool) {
        if valid {
            self.urlCheckLabel.text = "Valid"
            //self.urlCheckImageView.image = UIImage(named: "")
            self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
            self.urlCheckLabel.text = "Invalid"
            //self.urlCheckImageView.image = UIImage(named: "")
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    //MARK: - TextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let text = textField.text + string
        if(text.isEmpty || !text.isUrl()) {
            setValidLabelAndImage(false)
            
        } else {
            setValidLabelAndImage(true)
            // allow them to hit add -> then go to preview where we will have errors if it is not well formed
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        let text = textField.text
        if(text.isEmpty || !text.isUrl()) {
            setValidLabelAndImage(false)
                
        } else {
            setValidLabelAndImage(true)
            // allow them to hit add -> then go to preview where we will have errors if it is not well formed
        }

    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {        
        return true
    }

    //MARK: - UIPickerDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    //MARK: - UIPickerDelegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if(row <= self.pickerData.count) {
            let typeAsString: String = self.pickerData[row]
            displayFeed.type = RSSType.typeFromString(typeAsString)
        }
    }
    
    //MARK: - Actions
    
    @IBAction func nextTapped(sender: UIBarButtonItem) {
        
        let inputUrl: String = self.urlFeild.text
        self.newsManager.testNewRSSUrl(inputUrl, type: displayFeed.type)
        

        // display the preview if it is
        // and then send it to our server for storage
        // close this popover 
        // update list
    }
}
