//
//  BaseImageSegmentCollectionViewCell.swift
//  DevKit
//
//  Created by Nang Nguyen on 5/7/19.
//  Copyright © 2019 Evizi. All rights reserved.
//

import Foundation

class BaseImageSegmentCollectionViewCell: BaseSegmentCollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = BaseSegmentCollectionViewCell.defaultFont
        return titleLabel
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.spacing = BaseSegmentCollectionViewCell.textPadding
        return stackView
    }()
    
    override var contentColor:UIColor? {
        didSet {
            titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
        }
    }
    
    override var selectedContentColor:UIColor? {
        didSet {
            titleLabel.highlightedTextColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if let title = (isHighlighted) ? super.highlightedAttributedTitle : super.normalAttributedTitle {
                titleLabel.attributedText = title
            } else {
                titleLabel.isHighlighted = isHighlighted
            }
            
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
                if let title = super.selectedAttributedTitle {
                    titleLabel.attributedText = title
                } else {
                    titleLabel.textColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
                }
                imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
            } else {
                if let title = super.normalAttributedTitle {
                    titleLabel.attributedText = title
                } else {
                    titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
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
    
    func setupViewHierarchy() {
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        
        contentView.addSubview(stackView)
        contentView.addSubview(underlineView)
    }
    
    func setupConstraints() {
        stackView
            .centerXAnchor(equalTo: contentView.centerXAnchor)
            .centerYAnchor(equalTo: contentView.centerYAnchor)
            .leadingAnchor(greaterThanOrEqualTo: contentView.leadingAnchor, constant: BaseSegmentCollectionViewCell.textPadding)
        
        contentView
            .trailingAnchor(greaterThanOrEqualTo: stackView.trailingAnchor, constant: BaseSegmentCollectionViewCell.textPadding)
        
        underlineView
            .heightAnchor(equalTo: BaseSegmentCollectionViewCell.underlineHeight)
            .leadingAnchor(equalTo: contentView.leadingAnchor)
            .trailingAnchor(equalTo: contentView.trailingAnchor)
            .bottomAnchor(equalTo: contentView.bottomAnchor)
        
    }
    
    override func setup(_ viewModel: ViewModel) {
        super.setup(viewModel)
        
        titleLabel.text = viewModel.title
        imageView.image = viewModel.image
    }
    
    override func configCell(_ viewModel: ViewModel) {
        setup(viewModel)
    }
}
