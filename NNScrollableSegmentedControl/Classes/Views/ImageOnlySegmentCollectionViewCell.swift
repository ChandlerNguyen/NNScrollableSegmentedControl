//
//  ImageOnlySegmentCollectionViewCell.swift
//  DevKit
//
//  Created by Nang Nguyen on 5/7/19.
//  Copyright © 2019 Evizi. All rights reserved.
//

import Foundation

class ImageOnlySegmentCollectionViewCell: BaseSegmentCollectionViewCell {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = BaseSegmentCollectionViewCell.defaultTextColor
        return imageView
    }()
    
    override var contentColor:UIColor? {
        didSet {
            imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
            } else {
                imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
            } else {
                imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    private func setupViewHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(underlineView)
    }
    
    private func setupConstraints() {
        imageView
            .centerXAnchor(equalTo: contentView.centerXAnchor)
            .centerYAnchor(equalTo: contentView.centerYAnchor)
            .leadingAnchor(greaterThanOrEqualTo: contentView.leadingAnchor, constant: BaseSegmentCollectionViewCell.textPadding)
        
        contentView
            .trailingAnchor(greaterThanOrEqualTo: imageView.trailingAnchor, constant: BaseSegmentCollectionViewCell.textPadding)
        
        underlineView
            .heightAnchor(equalTo: BaseSegmentCollectionViewCell.underlineHeight)
            .leadingAnchor(equalTo: contentView.leadingAnchor)
            .trailingAnchor(equalTo: contentView.trailingAnchor)
            .bottomAnchor(equalTo: contentView.bottomAnchor)
        
    }
    
    override func setup(_ viewModel: ViewModel) {
        super.setup(viewModel)
        imageView.image = viewModel.image
    }
    
    override func configCell(_ viewModel: ViewModel) {
        setup(viewModel)
    }
}
