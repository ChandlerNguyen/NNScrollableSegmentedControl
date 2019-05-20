//
//  SegmentCellWithImageBeforeLabel.swift
//  DevKit
//
//  Created by Nang Nguyen on 5/7/19.
//  Copyright © 2019 Evizi. All rights reserved.
//

import Foundation

class SegmentCellWithImageBeforeLabel: BaseImageSegmentCell {
    
    override func setupConstraints() {
        super.setupConstraints()
        stackView.axis = .horizontal
        
        var imgFrame = imageView.frame
        imgFrame.size = CGSize(width: BaseSegmentCell.imageSize, height: BaseSegmentCell.imageSize)
        imageView.frame = imgFrame
        
        imageView
            .heightAnchor(equalTo: BaseSegmentCell.imageSize)
            .widthAnchor(equalTo: BaseSegmentCell.imageSize)
    }
    
}
