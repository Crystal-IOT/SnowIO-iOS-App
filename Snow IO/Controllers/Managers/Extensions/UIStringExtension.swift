//
//  UIStringExtension.swift
//  Snow IO
//
//  Created by Steven F. on 04/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}
