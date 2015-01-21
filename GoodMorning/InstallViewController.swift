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
    
    private let errorColor : UIColor = UIColor( red: 176, green: 35, blue: 14, alpha: 1.0 )
    private let defualtColor : UIColor = UIColor( red: 0.5, green: 0.5, blue:0, alpha: 1.0 )
    
    private let alert = UIAlertView()
    
    private var blur: UIVisualEffectView!
    
    @IBOutlet weak var activityIndicator: DTIActivityIndicatorView!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var descriptionLabel : UILabel!
    @IBOutlet var nameErrorLabel : UILabel!
    @IBOutlet var emailErrorLabel : UILabel!
    @IBOutlet var nameField : UITextField!
    @IBOutlet var emailField : UITextField!
    @IBOutlet var submitButton: UIButton!
    
    private let manager: InstallManager = InstallManager()
    private let speaker: TextToSpeech = TextToSpeech(enabled: true)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        nameField.delegate = self
        emailField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name:"NetworkError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InternalServerError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InvalidInstallResponse", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInstallComplete:", name:"InstallComplete", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name:"LocationDenied", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name:"LocationDisabled", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationUnknown:", name:"LocationUnknown", object: nil)
        
        blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
        blur.frame = view.frame
        blur.tag = 50
    }
    
    override func viewDidAppear(animated: Bool) {
        
        resetErrorLabelsAndColorsForField(nameField)
        resetErrorLabelsAndColorsForField(emailField)
        
        if(!Reachability.isConnectedToNetwork()) {
            alert.title = "Network Connection"
            alert.message = "You don't appear to be connected to the Internet. Please check your connection."
            alert.addButtonWithTitle("Ok")
            alert.show()
        } else {
            LocationManager.sharedInstance.update()
        }
        
        // TODO: enable when done install
        //speaker.speakStringsWithPause(titleLabel.text!, words2: descriptionLabel.text!, pauseLength: 2)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
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
    
    func receivedNetworkError(notification: NSNotification) {
        stopLoading()
        
        alert.title = "Network Error"
        alert.message = "Please check your network connection"
        alert.addButtonWithTitle("Ok")
        alert.show()
        
        setUIElementsEnabled(true)
    }
    
    func receivedInternalServerError(notification: NSNotification) {
        stopLoading()
        
        alert.title = getUserInfoValueForKey(notification.userInfo, "reason")
        alert.message = getUserInfoValueForKey(notification.userInfo, "message")
        alert.addButtonWithTitle("Dismiss")
        alert.show()
        
        setUIElementsEnabled(true)
    }
    
    func receivedLocationAuthorizeProblem(notification: NSNotification) {
        stopLoading()
        alert.title = "Location Services Disallowed"
        alert.message = "Because you have disallowed location services you are required to enter your country and city in order to use GoodMorning"
        alert.addButtonWithTitle("Ok")
        alert.show()
        
        // add a field to the install view to hard code location
        
        // use the weather api with a city and country code
        // example:  api.openweathermap.org/data/2.5/weather?q=London,uk
    }
    
    func receivedInstallComplete(notification: NSNotification) {
        stopLoading()
        performSegueWithIdentifier("InstallationComplete", sender: self)
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
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}