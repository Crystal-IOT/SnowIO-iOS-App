//
//  UIViewExtension.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setupViewController() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "bg")
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    // Mark : Empty Message on View
    func showEmptyMessage(localizedKeyString: String) {
        let emptyLabel: UILabel = UILabel(frame: CGRect(x: 0,
                                                        y: -96,
                                                        width: view.frame.width,
                                                        height: view.frame.height))
        
        emptyLabel.text = NSLocalizedString(localizedKeyString, comment: "")
        emptyLabel.textColor = UIColor.black
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 5
        emptyLabel.font = UIFont.boldSystemFont(ofSize: emptyLabel.font.pointSize)
        view.addSubview(emptyLabel)
    }
    
    func removeEmptyMessage() {
        for subview in view.subviews {
            if subview is UILabel {
                subview.removeFromSuperview()
            }
        }
    }
}
