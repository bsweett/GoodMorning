//
//  AlarmViewCell.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-03-15.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class AlarmViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var enabledSwitch: UISwitch!
    
    private var alarm: Task!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setAlarmTask(task: Task) {
        if(task.type == TaskType.ALARM) {
            self.alarm = task
            setTitleLabel(task.title)
            setTimeLabel(task.displayAlertTime())
            setDaysLabel(task.daysOfWeekToDisplayString())
            
            var list = NotificationManager.sharedInstance.findNotificationsForTask(task)
            if list.count > 0 {
                self.enabledSwitch.on = true
            } else {
                self.enabledSwitch.on = false
            }
            
        } else {
            NSLog("Warning: cannot set alarm cell with a task that is not of type ALARM")
        }
    }
    
    func setTitleLabel(value: String) {
        self.titleLabel.text = value
    }
    
    func setTimeLabel(value: String) {
        self.timeLabel.text = value
    }
    
    func setDaysLabel(value: String) {
        self.daysLabel.text = value
    }
    
    func getAlarm() -> Task {
        return self.alarm
    }
    
    @IBAction func toggleAlarm(sender: UISwitch) {
        if sender.on {
            NotificationManager.sharedInstance.scheduleNotificationForTask(self.alarm)
        } else {
            NotificationManager.sharedInstance.cancelNotificationsForTask(self.alarm)
        }
    }
}
