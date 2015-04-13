//
//  TaskViewCell.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-07.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class TaskViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var customLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var notificationImageView: UIImageView!
    
    private var task: Task!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setTaskObject(task: Task) {
        self.task = task
        self.setName(task.title)
        self.setTime(task.displayAlertTime())
        self.setDays(task.daysOfWeekToDisplayString())
        self.setType(task.type)
        self.setNotification(task.displaySoundEnabledFlag())
    }
    
    func getTaskObject() -> Task {
        return self.task
    }
    
    func setName(value: String) {
        self.nameLabel.text = value
    }
    
    func setTime(value: String) {
        self.timeLabel.text = value
    }
    
    func setDays(value: String) {
        self.daysLabel.text = value
    }
    
    func setType(type: TaskType) {
        
        self.typeLabel.text = type.rawValue
        
        switch(type) {
        case TaskType.CHORE:
            self.typeImageView.image = UIImage(named: "gm_chore")
            break
        case TaskType.ENTERTAINMENT:
            self.typeImageView.image = UIImage(named: "gm_entertainment")
            break
        case TaskType.ALARM:
            self.typeImageView.image = UIImage(named: "gm_alarm")
            break
        case TaskType.TRAVEL:
            self.typeImageView.image = UIImage(named: "gm_travel")
            break
        default:
            break
        }
    }
    
    func setCustom(value: String) {
        
        // TODO: Custom label
    }
    
    func setNotification(value: String) {
        if (value.lowercaseString.rangeOfString("sound") != nil) {
            notificationImageView.image = UIImage(named: "gm_sound_notif")
        } else {
            notificationImageView.image = UIImage(named: "gm_notif")
        }
    }
}
