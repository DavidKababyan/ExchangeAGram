//
//  FilterCell.swift
//  ExchangeAGram
//
//  Created by David Kababyan on 2/7/15.
//  Copyright (c) 2015 David Kababyan. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
   override init(frame: CGRect) {
        
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        contentView.addSubview(imageView)
    }

   required init(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
    
    
}
