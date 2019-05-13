//
//  ImageOnLeftSegmentCollectionViewCell.swift
//  DevKit
//
//  Created by Nang Nguyen on 5/7/19.
//  Copyright © 2019 Evizi. All rights reserved.
//

import Foundation

class ImageOnLeftSegmentCollectionViewCell: BaseImageSegmentCollectionViewCell {
    
    override func setupConstraints() {
        super.setupConstraints()
        stackView.axis = .horizontal
        
        var imgFrame = imageView.frame
        imgFrame.size = CGSize(width: BaseSegmentCollectionViewCell.imageSize, height: BaseSegmentCollectionViewCell.imageSize)
        imageView.frame = imgFrame
        
        imageView
            .heightAnchor(equalTo: BaseSegmentCollectionViewCell.imageSize)
            .widthAnchor(equalTo: BaseSegmentCollectionViewCell.imageSize)
    }
    
}
