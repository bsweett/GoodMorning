//
//  ArticleViewCell.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-24.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class ArticleViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbNailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    private var article: RSSArticle!
    private var link: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setArticle(article: RSSArticle) {
        self.article = article
        setTitleLabel(article.title)
        setDescriptionLabel(article.textDescription)
        setDetailLabel(article.creator, date: article.pubdate.toFullDateString())   //TODO: Compare this to our current date (1 hour ago etc..)
        
        self.link = article.link
    }
    
    func getArticle() -> RSSArticle {
        return self.article
    }
    
    func getLink() -> String {
        return self.link
    }
    
    func setTitleLabel(value: String) {
        self.titleLabel.text = value
    }
    
    func setDescriptionLabel(value: String) {
        self.descriptionLabel.text = value
    }
    
    func setDetailLabel(author: String, date: String) {
        self.detailLabel.text = "by " + author + " / " + date
    }
    
    func setThumbNailImage(image: UIImage?) {
        self.thumbNailImageView.image = image
        self.article.image = image
    }
    
}
