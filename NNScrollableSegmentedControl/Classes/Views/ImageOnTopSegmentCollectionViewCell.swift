//
//  ImageOnTopSegmentCollectionViewCell.swift
//  DevKit
//
//  Created by Nang Nguyen on 5/7/19.
//  Copyright © 2019 Evizi. All rights reserved.
//

import Foundation

class ImageOnTopSegmentCollectionViewCell: BaseImageSegmentCollectionViewCell {
    
    override func setupConstraints() {
        super.setupConstraints()
        stackView.axis = .vertical
    }
}
