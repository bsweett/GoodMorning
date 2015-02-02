//
//  TaskTypeViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-28.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class TaskTypeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var taskTypePicker: UIPickerView!
    
    var pickerData: [String]!
    var selection: String! = ""
    var delegate: popOverNavDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerData = TaskType.displayValues
        
        self.navigationItem.title = "Type"
        
        self.taskTypePicker.dataSource = self
        self.taskTypePicker.delegate = self
        self.setPickerViewForSelection()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.saveType(self.selection)
    }
    
    override func viewDidDisappear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setSelection(text: String) {
        self.selection = text
    }
    
    func setPickerViewForSelection() {
        if(contains(self.pickerData, self.selection)) {
            self.taskTypePicker.selectRow(find(self.pickerData, self.selection)!, inComponent: 0, animated: true)
        }
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
            self.selection = self.pickerData[row]
        }
    }

}
