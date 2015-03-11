//
//  NewsViewCell.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-15.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class NewsViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    private var newsFeed: RSSFeed!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setNewsFeed(feed: RSSFeed) {
        self.newsFeed = feed
        self.setTitleLabel(feed.title)
        self.setDescriptionLabel(feed.contentDescription)
        
        var lastActive = feed.lastActiveDate
        var daysSince = lastActive.differenceToNow(NSCalendarUnit.DayCalendarUnit).day
        var hoursSince = lastActive.differenceToNow(NSCalendarUnit.HourCalendarUnit).hour
        var minutesSince = lastActive.differenceToNow(NSCalendarUnit.MinuteCalendarUnit).minute
        var displayString = ""
        
        
        if(daysSince >= 1) {
            if(daysSince == 1) {
                displayString = String(daysSince) + " day ago"
            } else {
                displayString = String(daysSince) + " days ago"
            }
        } else if(hoursSince >= 1) {
            if(hoursSince == 1) {
                displayString = String(hoursSince) + " hour ago"
            } else {
                displayString = String(hoursSince) + " hours ago"
            }
        } else if(minutesSince == 1) {
            displayString = String(minutesSince) + " minute ago"
        } else {
            displayString = String(minutesSince) + " minutes ago"
        }
        
        self.setDateLabel(displayString)
    }
    
    func getNewsFeedObject() -> RSSFeed {
        return self.newsFeed
    }
    
    func setTitleLabel(value: String) {
        self.titleLabel.text = value
    }
    
    func setDescriptionLabel(value: String) {
        self.descriptionLabel.text = value
    }

    func setThumbnailLogo(value: UIImage?) {
        self.logoImageView.image = value
    }
    
    func setDateLabel(value: String) {
        self.dateLabel.text = value
    }
    
    func layoutMargins() -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
}
