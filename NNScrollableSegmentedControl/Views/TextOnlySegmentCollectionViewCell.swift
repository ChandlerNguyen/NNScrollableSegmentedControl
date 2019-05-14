//
//  TextOnlySegmentCollectionViewCell.swift
//  NNScrollableSegmentedControl
//
//  Created by Nang Nguyen on 5/13/19.
//

import UIKit

class TextOnlySegmentCollectionViewCell: BaseSegmentCollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = BaseSegmentCollectionViewCell.defaultTextColor
        label.font = BaseSegmentCollectionViewCell.defaultFont
        return label
    }()
    
    override var contentColor:UIColor? {
        didSet {
            titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
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
            } else {
                if let title = super.normalAttributedTitle {
                    titleLabel.attributedText = title
                } else {
                    titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(underlineView)
    }
    
    private func setupConstraints() {
        titleLabel
            .centerXAnchor(equalTo: contentView.centerXAnchor)
            .centerYAnchor(equalTo: contentView.centerYAnchor)
            .leadingAnchor(equalTo: contentView.leadingAnchor, constant: BaseSegmentCollectionViewCell.textPadding)
            .trailingAnchor(equalTo: contentView.trailingAnchor, constant: -BaseSegmentCollectionViewCell.textPadding)
        
        underlineView
            .heightAnchor(equalTo: BaseSegmentCollectionViewCell.underlineHeight)
            .leadingAnchor(equalTo: contentView.leadingAnchor)
            .trailingAnchor(equalTo: contentView.trailingAnchor)
            .bottomAnchor(equalTo: contentView.bottomAnchor)
        
    }
    
    override func setup(_ viewModel: ViewModel) {
        super.setup(viewModel)
        
        titleLabel.text = viewModel.title
    }
    
    override func configCell(_ viewModel: ViewModel) {
        setup(viewModel)
    }
}
