//
//  DesignExtension.swift
//  Snow IO
//
//  Created by Steven F. on 05/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit


// MARK : - CUSTOM IMAGE VIEW
class imageCircleView: UIImageView {
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}

class imageRoundedView: UIImageView {
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.size.height / 4
        self.clipsToBounds = true
    }
}


// MARK : CUSTOM UIVIEW
class CircleView: UIView {
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}


// MARK : CUSTOM BUTTON
class actionButtons: UIButton {
    override func awakeFromNib() {
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .black
        self.layer.cornerRadius = self.bounds.height/2
    }
    
    func disableButton() {
        self.backgroundColor = .gray
        self.isEnabled = false
    }
    
    func enabledButton() {
        self.backgroundColor = .black
        self.isEnabled = true
    }
}
