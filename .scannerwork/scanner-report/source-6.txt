//
//  LoadingBarView.swift
//  CloudWeather
//
//  Created by Steven F. on 21/03/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit
import KDLoadingView

@IBDesignable class LoadingBarView: UIView {
    
    @IBOutlet var mView: UIView!
    @IBOutlet weak var mLoading: KDLoadingView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        mView = loadViewFromNib()
       
        mView.frame = CGRect(x: 0,
                             y: 0,
                             width: UIScreen.main.bounds.width,
                             height: UIScreen.main.bounds.height)
        
        addSubview(mView)
        mLoading.startAnimating()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "LoadingBarView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    

    // Coloration properties
    @IBInspectable
    public var Coloration: UIColor = UIColor.white {
        didSet {
            self.mLoading.backgroundColor = self.Coloration
        }
    }
    
    // LinesWidth properties
    @IBInspectable
    public var LinesWidth : CGFloat = 1.5 {
        didSet {
            self.mLoading.lineWidth = self.LinesWidth
        }
    }
    
    // Duration properties
    @IBInspectable
    public var Durations : CGFloat = 3 {
        didSet {
            self.mLoading.duration = self.Durations
        }
    }
}

