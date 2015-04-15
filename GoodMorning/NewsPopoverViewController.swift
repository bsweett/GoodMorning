//
//  NewsPopoverViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-15.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class NewsPopoverViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var typePicker: UIPickerView!
    
    var pickerData: [String]!
    
    var displayFeed: RSSFeed!
    var newsManager: NewsManager!
    var rootViewController: NewsViewController!
    
    var resultViewController: NewsResultsViewController!
    
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
        self.searchField.delegate = self
        self.navigationItem.rightBarButtonItem?.enabled = true
        
        var backButton = UIBarButtonItem(title: backButTitle, style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.typePicker.selectRow(0, inComponent: 0, animated: true)
        self.searchField.text = ""
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name: kNetworkError, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name: kInternalServerError, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedSearchResults:", name:"FeedlyResultsFound", object: nil)
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
        SCLAlertView().showWarning(internalErrTitle,
            subTitle:  reason + " - " + message, closeButtonTitle: dismissButTitle)
    }
    
    func receivedSearchResults(notification: NSNotification) {
        let feedDictionary = notification.userInfo as Dictionary<String,RSSFeed>
        
        var feedList: [RSSFeed]! = []
        
        for feed in feedDictionary.values {
            feedList.append(feed)
        }
        
        if(self.resultViewController == nil) {
            self.resultViewController = NewsResultsViewController(nibName: "NewsResultsViewController", bundle: nil)
        }
        
        self.resultViewController.setResultList(feedList)
        self.resultViewController.setRoot(self.rootViewController)
        self.navigationController?.pushViewController(resultViewController, animated: true)
    }
    
    //TODO: Error Label this
    func enabledButtonIfValid(valid: Bool) {

        if valid {
            self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    //MARK: - TextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let text = textField.text + string
        
        if (text.isEmpty) {
            enabledButtonIfValid(true)
            
        } else if(!text.isUrl() && !text.isAlphaNumeric()) {
            enabledButtonIfValid(false)
        } else {
            enabledButtonIfValid(true)
            
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        let text = textField.text
        if(text.isEmpty) {
            enabledButtonIfValid(true)
        }
        else if(!text.isUrl() && !text.isAlphaNumeric()) {
            enabledButtonIfValid(false)
            
        } else {
            enabledButtonIfValid(true)
            
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
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
        
        let inputSearch: String = self.searchField.text
        if(inputSearch.isEmpty) {
            self.newsManager.getFeedsForQuery(displayFeed.type.rawValue)
        } else {
            self.newsManager.getFeedsForQuery(inputSearch)
        }
    }
}
