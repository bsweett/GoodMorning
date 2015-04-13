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

    /**
    Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        arrowImageView.image = arrowImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        arrowImageView.tintColor = gmOrangeColor
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }

    /**
    Sets the selected state of the cell, optionally animating the transition between states.
    
    :param: selected YES to set the cell as selected, NO to set it as unselected.
    :param: animated YES to animate the transition between selected states, NO to make the transition immediate.
    */
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /**
    Sets the title label of the cell
    
    :param: title The title text to display
    */
    func setTitle(title: String) {
        self.titleLabel.text = title
    }
    
    /**
    Gets the title text from the label
    
    :returns: the title text String
    */
    func getTitle() -> String {
        return self.titleLabel.text!
    }
    
    /**
    Sets the value label of the cell
    
    :param: value The value text to display
    */
    func setValue(value: String) {
        self.valueLabel.text = value
    }
    
    /**
    Gets the value text from the label
    
    :returns: the value text String
    */
    func getValue() -> String {
        return self.valueLabel.text!
    }
    
    /**
    Hides the default arrow image from the cell
    */
    func hideArrowImageView() {
        arrowImageView.hidden = true
    }    
}
