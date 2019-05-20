//
//  SegmentCellWithImage.swift
//  DevKit
//
//  Created by Nang Nguyen on 5/7/19.
//  Copyright © 2019 Evizi. All rights reserved.
//

import Foundation

class SegmentCellWithImage: BaseSegmentCell {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = BaseSegmentCell.defaultTextColor
        return imageView
    }()
    
    override var contentColor:UIColor? {
        didSet {
            imageView.tintColor = (contentColor == nil) ? BaseSegmentCell.defaultTextColor : contentColor!
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCell.defaultTextColor : selectedContentColor!
            } else {
                imageView.tintColor = (contentColor == nil) ? BaseSegmentCell.defaultTextColor : contentColor!
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCell.defaultTextColor : selectedContentColor!
            } else {
                imageView.tintColor = (contentColor == nil) ? BaseSegmentCell.defaultTextColor : contentColor!
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
        contentView.addSubview(verticalSeparatorView)
    }
    
    private func setupConstraints() {
        imageView
            .centerXAnchor(equalTo: contentView.centerXAnchor)
            .centerYAnchor(equalTo: contentView.centerYAnchor)
            .leadingAnchor(greaterThanOrEqualTo: contentView.leadingAnchor, constant: BaseSegmentCell.textPadding)
        
        contentView
            .trailingAnchor(greaterThanOrEqualTo: imageView.trailingAnchor, constant: BaseSegmentCell.textPadding)
        
        verticalSeparatorView
            .topAnchor(equalTo: contentView.topAnchor)
            .bottomAnchor(equalTo: contentView.bottomAnchor)
            .trailingAnchor(equalTo: contentView.trailingAnchor)
            .widthAnchor(equalTo: 1)
    }
    
    override func setup(_ viewModel: ViewModel, isLastCell: Bool) {
        super.setup(viewModel, isLastCell: isLastCell)
        imageView.image = viewModel.image
    }
    
    override func configCell(_ viewModel: ViewModel, isLastCell: Bool) {
        setup(viewModel, isLastCell: isLastCell)
    }
}
