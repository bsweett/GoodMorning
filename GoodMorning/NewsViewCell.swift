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
    @IBOutlet weak var typeLabel: UILabel!
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
        self.setTypeLabel(feed.type)
        self.setDateLabel(feed.lastActiveDate.toFullDateString())
        
        if feed.logoURL != nil {
            self.setLogoImageFromURL(feed.logoURL)
        } else {
            
            // TODO: Question mark image if it cannot find the logo
            self.logoImageView.image = UIImage(named: "gm_unknown")
        }
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
    
    func setTypeLabel(value: RSSType) {
        self.typeLabel.text = value.rawValue
    }
    
    func setLogoImageFromURL(url: String) {
        let url = NSURL(string: url)
        if let data = NSData(contentsOfURL: url!) {
            self.logoImageView.image = UIImage(data: data)
        }
    }
    
    func setDateLabel(value: String) {
        self.dateLabel.text = value
    }
    
}
