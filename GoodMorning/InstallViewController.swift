//
//  InstallViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-18.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import DTIActivityIndicator

class InstallViewController : UIViewController, UITextFieldDelegate {
    
    // MARK: - Constants
    
    private let errorColor : UIColor = UIColor( red: 176, green: 35, blue: 14, alpha: 1.0 )
    private let defualtColor : UIColor = UIColor( red: 0.5, green: 0.5, blue:0, alpha: 1.0 )
    
    private let manager: InstallManager = InstallManager()
    
    // MARK: - Variables
    
    private var blur: UIVisualEffectView!
    
    @IBOutlet weak var activityIndicator: DTIActivityIndicatorView!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var descriptionLabel : UILabel!
    @IBOutlet var nameErrorLabel : UILabel!
    @IBOutlet var emailErrorLabel : UILabel!
    @IBOutlet var nameField : UITextField!
    @IBOutlet var emailField : UITextField!
    
    @IBOutlet weak var newsButton: UIButton!
    @IBOutlet weak var businessButton: UIButton!
    @IBOutlet weak var scienceButton: UIButton!
    @IBOutlet weak var techButton: UIButton!
    @IBOutlet weak var sports: UIButton!
    @IBOutlet weak var lifeStyleButton: UIButton!
    @IBOutlet weak var entertainmentButton: UIButton!
    
    private var newsSelected: Bool! = false
    private var busSelected: Bool! = false
    private var sciSelected: Bool! = false
    private var techSelected: Bool! = false
    private var sportsSelected: Bool! = false
    private var lifeSelected: Bool! = false
    private var entertainSelected: Bool! = false
    
    @IBOutlet var submitButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        nameField.delegate = self
        emailField.delegate = self
        
        initCheckButtons()
        
        blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blur.frame = view.frame
        blur.tag = 50
    }
    
    override func viewDidAppear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name: kNetworkError, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name: kInternalServerError, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name: kInvalidInstallResponse, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInstallComplete:", name: kInstallComplete, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name: kLocationDenied, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name: kLocationDisabled, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationUnknown:", name: kLocationUnknown, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedExistingUserData:", name: kExistingAccountFound, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedCleanInstall:", name: kSafeToInstall, object: nil)
        
        resetErrorLabelsAndColorsForField(nameField)
        resetErrorLabelsAndColorsForField(emailField)
        
        if(!Reachability.isConnectedToNetwork()) {
            SCLAlertView().showNotice("No Network Connection",
                subTitle: "You don't appear to be connected to the Internet. Please check your connection.",
                duration: 6)
        } else {
            startLoading()
            LocationManager.sharedInstance.update()
            manager.sendNewAppConnectionRequest()
        }
        
        let speaker: TextToSpeech = TextToSpeech()
        speaker.speakStringsWithPause(titleLabel.text!, words2: descriptionLabel.text!, pauseLength: 2)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    private func initCheckButtons() {
        let selectedCheckImage = UIImage(named: "gm_check")
        let cornerRadius: CGFloat = 5
        let borderWidth: CGFloat = 1
        let black = UIColor.lightGrayColor().CGColor
        
        newsButton.layer.cornerRadius = cornerRadius
        newsButton.layer.borderWidth = borderWidth
        newsButton.layer.borderColor = black
        
        businessButton.layer.cornerRadius = cornerRadius
        businessButton.layer.borderWidth = borderWidth
        businessButton.layer.borderColor = black
        
        scienceButton.layer.cornerRadius = cornerRadius
        scienceButton.layer.borderWidth = borderWidth
        scienceButton.layer.borderColor = black
        
        techButton.layer.cornerRadius = cornerRadius
        techButton.layer.borderWidth = borderWidth
        techButton.layer.borderColor = black
        
        sports.layer.cornerRadius = cornerRadius
        sports.layer.borderWidth = borderWidth
        sports.layer.borderColor = black
        
        lifeStyleButton.layer.cornerRadius = cornerRadius
        lifeStyleButton.layer.borderWidth = borderWidth
        lifeStyleButton.layer.borderColor = black
        
        entertainmentButton.layer.cornerRadius = cornerRadius
        entertainmentButton.layer.borderWidth = borderWidth
        entertainmentButton.layer.borderColor = black

        newsButton.setBackgroundImage(selectedCheckImage, forState: UIControlState.Selected)
        businessButton.setBackgroundImage(selectedCheckImage, forState: UIControlState.Selected)
        scienceButton.setBackgroundImage(selectedCheckImage, forState: UIControlState.Selected)
        techButton.setBackgroundImage(selectedCheckImage, forState: UIControlState.Selected)
        sports.setBackgroundImage(selectedCheckImage, forState: UIControlState.Selected)
        lifeStyleButton.setBackgroundImage(selectedCheckImage, forState: UIControlState.Selected)
        entertainmentButton.setBackgroundImage(selectedCheckImage, forState: UIControlState.Selected)

        newsButton.setBackgroundImage(selectedCheckImage, forState: UIControlState.Highlighted)
        businessButton.setBackgroundImage(selectedCheckImage, forState: UIControlState.Highlighted)
        scienceButton.setBackgroundImage(selectedCheckImage, forState: UIControlState.Highlighted)
        techButton.setBackgroundImage(selectedCheckImage, forState: UIControlState.Highlighted)
        sports.setBackgroundImage(selectedCheckImage, forState: UIControlState.Highlighted)
        lifeStyleButton.setBackgroundImage(selectedCheckImage, forState: UIControlState.Highlighted)
        entertainmentButton.setBackgroundImage(selectedCheckImage, forState: UIControlState.Highlighted)
        
        newsButton.adjustsImageWhenHighlighted = true
        businessButton.adjustsImageWhenHighlighted = true
        scienceButton.adjustsImageWhenHighlighted = true
        techButton.adjustsImageWhenHighlighted = true
        sports.adjustsImageWhenHighlighted = true
        lifeStyleButton.adjustsImageWhenHighlighted = true
        entertainmentButton.adjustsImageWhenHighlighted = true
    }
    
    // MARK: - Actions
    
    @IBAction func checkBoxTapped(sender: UIButton) {
        switch(sender.tag) {
        case 1:
            newsSelected = !newsSelected
            sender.selected = newsSelected
        case 2:
            busSelected = !busSelected
            sender.selected = busSelected
        case 3:
            sciSelected = !sciSelected
            sender.selected = sciSelected
        case 4:
            techSelected = !techSelected
            sender.selected = techSelected
        case 5:
            sportsSelected = !sportsSelected
            sender.selected = sportsSelected
        case 6:
            lifeSelected = !lifeSelected
            sender.selected = lifeSelected
        case 7:
            entertainSelected = !entertainSelected
            sender.selected = entertainSelected
        default:
            break
        }
    }
    
    @IBAction func submitButtonAction(sender:UIButton!) {
        
        setUIElementsEnabled(false)
        
        let nickname = nameField.text
        let email = emailField.text
        var valid: Bool = true
        
        if(email.isEmpty || !email.isEmail()) {
            setErrorLabelForField(emailField)
            valid = false
            
        }
        
        if(nickname.isEmpty || !nickname.isName()) {
            setErrorLabelForField(nameField)
            valid = false
            
        }
        
        if(valid) {
            startLoading()
            manager.sendInstallRequestForUser(nickname, email: email)
            
        } else {
            setUIElementsEnabled(true)
            
        }
    }
    
    // MARK: - UI State Control
    
    private func setUIElementsEnabled(enabled: Bool) {
        submitButton.enabled = enabled
        nameField.enabled = enabled
        emailField.enabled = enabled
    }
    
    private func setErrorLabelForField(textField: UITextField) {
        
        textField.layer.borderColor = errorColor.CGColor
        
        if(textField == nameField) {
            nameErrorLabel.text = "Invalid Name"
            
        } else if (textField == emailField) {
            emailErrorLabel.text = "Invalid Email"
            
        }
        
    }
    
    private func resetErrorLabelsAndColorsForField(textField: UITextField) {
        
        textField.layer.borderColor = defualtColor.CGColor
        
        if(textField == nameField) {
            nameErrorLabel.text = ""
            
        } else if (textField == emailField) {
            emailErrorLabel.text = ""
            
        }
    }
    
    
    func startLoading() {
        self.view.addSubview(blur)
        activityIndicator.startActivity()
        self.view.bringSubviewToFront(activityIndicator)
    }
    
    func stopLoading() {
        blur.removeFromSuperview()
        activityIndicator.stopActivity()
    }
    
    // MARK: - TextField Delegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        let text = textField.text
        
        if(textField == nameField) {
            if(text.isEmpty || !text.isName()) {
                setErrorLabelForField(textField)
                
            } else {
                resetErrorLabelsAndColorsForField(textField)
            }
            
        } else if(textField == emailField) {
            if(text.isEmpty || !text.isEmail()) {
                setErrorLabelForField(textField)
                
            } else {
                resetErrorLabelsAndColorsForField(textField)
                
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        
        if (textField == nameField) {
            emailField.becomeFirstResponder()
            
        } else if(textField == emailField) {
            emailField.resignFirstResponder()
            
        }
        
        return true
    }
    
    // MARK: - Notification Handlers
    
    func receivedNetworkError(notification: NSNotification) {
        stopLoading()
        
        SCLAlertView().showError(networkErrTitle,
            subTitle: "Oops something went wrong",
            closeButtonTitle: "Dismiss")
        
        setUIElementsEnabled(true)
    }
    
    func receivedInternalServerError(notification: NSNotification) {
        stopLoading()
        
        let reason = getUserInfoValueForKey(notification.userInfo, "reason")
        let message = getUserInfoValueForKey(notification.userInfo, "message")
        SCLAlertView().showWarning(internalErrTitle,
            subTitle:  reason + " - " + message, closeButtonTitle: dismissButTitle)
        
        setUIElementsEnabled(true)
    }
    
    func receivedLocationAuthorizeProblem(notification: NSNotification) {
        stopLoading()
        
        SCLAlertView().showWarning("Location Services Disallowed",
            subTitle: "Because you have disallowed location services you are required to enter your country and city in order to use GoodMorning", closeButtonTitle: okButTitle)
        
        // add a field to the install view to hard code location
        
        // use the weather api with a city and country code
        // example:  api.openweathermap.org/data/2.5/weather?q=London,uk
    }
    
    func receivedExistingUserData(notification: NSNotification) {
        stopLoading()
        let infoDict = notification.userInfo as Dictionary<String, User>!
        let user: User = infoDict["user"]!
        let name = user.nickname
        
        let alert = SCLAlertView()
        alert.addButton("Use Existing Account") {
            UserDefaultsManager.sharedInstance.clearUserDefaults()
            UserDefaultsManager.sharedInstance.saveUserData(user)
            self.performSegueWithIdentifier("InstallationComplete", sender: self)
        }
        
        alert.addButton("Create A New Account") {
            self.manager.sendUninstallRequestForUser(user)
            self.startLoading()
        }
        
        alert.showInfo("Existing Account Found", subTitle: "This device is registered with another account owned by " + name.capitalizedString + ". You can choose to use this account or install a new one. If you choose to make a new account the existing account will be erased.")
        
    }

    func receivedCleanInstall(notification: NSNotification) {
        stopLoading()
        UserDefaultsManager.sharedInstance.clearUserDefaults()
    }
    
    func receivedInstallComplete(notification: NSNotification) {
        let infoDict = notification.userInfo as Dictionary<String, User>!
        let user: User = infoDict["user"]!
        
        stopLoading()
        UserDefaultsManager.sharedInstance.saveUserData(user)
        performSegueWithIdentifier("InstallationComplete", sender: self)
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}