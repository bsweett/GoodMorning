//
//  TaskNotesViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-01.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class TaskNotesViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var delegate: popOverNavDelegate?
    var notes: String = ""
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Notes"
        
        notesTextView.layer.cornerRadius = radius
        notesTextView.layer.borderColor = gmOrangeColor.CGColor
        notesTextView.layer.borderWidth = 1
        
        notesTextView.delegate = self
        
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard:"))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.notesTextView.text = notes
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        if((notesTextView.text as NSString).length < 501) {
            delegate?.saveNotes(notesTextView.text)
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func setNotes(text: String) {
        self.notes = text
    }
    
    func displayErrorForTime(text: String, time: Double) {
        
        if(self.errorLabel.text == "") {
            self.errorLabel.fadeIn(duration: 2.0, completion: {
                (finished: Bool) -> Void in
                self.errorLabel.text = text
                self.errorLabel.fadeOut(delay: time, completion: {
                    (finished: Bool) -> Void in
                    self.errorLabel.text = ""
                })
            })
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if((textView.text as NSString).length > 500) {
            textView.becomeFirstResponder()
            displayErrorForTime("Notes cannot be longer than 500 characters", time: 5.0)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

}
