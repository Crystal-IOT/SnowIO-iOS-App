//
//  UITextViewExtension.swift
//  Snow IO
//
//  Created by Steven F. on 26/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

extension UITextView {
    
    /// Modifies the top content inset to center the text vertically.
    func alignTextVerticallyInContainer() {
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrect = topCorrect/2
        self.contentInset.top = topCorrect
    }
}
