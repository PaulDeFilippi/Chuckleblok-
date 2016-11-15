//
//  CIrcleView.swift
//  lets-get-social
//
//  Created by Paul Defilippi on 10/12/16.
//  Copyright © 2016 Paul Defilippi. All rights reserved.
//

import UIKit

class CIrcleView: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
        
    }

}
