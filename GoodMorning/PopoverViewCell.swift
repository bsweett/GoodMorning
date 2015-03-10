//
//  PopoverViewCell.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-27.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class PopoverViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UITextView!
    @IBOutlet weak var arrowImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        arrowImageView.image = arrowImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        arrowImageView.tintColor = gmOrangeColor
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setTitle(title: String) {
        self.titleLabel.text = title
    }
    
    func getTitle() -> String {
        return self.titleLabel.text!
    }
    
    func setValue(value: String) {
        self.valueLabel.text = value
    }
    
    func getValue() -> String {
        return self.valueLabel.text!
    }
    
    func hideArrowImageView() {
        arrowImageView.hidden = true
    }
    
    // TODO: Hide Image and replace with switch for some cells
    
}
