//
//  SegmentCellWithLabel.swift
//  NNScrollableSegmentedControl
//
//  Created by Nang Nguyen on 5/13/19.
//

import UIKit

class SegmentCellWithLabel: BaseSegmentCell {
    
    lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = BaseSegmentCell.defaultTextColor
        label.font = BaseSegmentCell.defaultFont
        return label
    }()
    
    override var contentColor:UIColor? {
        didSet {
            titleLabel.textColor = (contentColor == nil) ? BaseSegmentCell.defaultTextColor : contentColor!
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
            backgroundColor = isHighlighted ? .yellow : .clear
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
                    titleLabel.textColor = (contentColor == nil) ? BaseSegmentCell.defaultTextColor : contentColor!
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
        contentView.addSubview(verticalSeparatorView)
    }
    
    private func setupConstraints() {
        titleLabel
            .centerXAnchor(equalTo: contentView.centerXAnchor)
            .centerYAnchor(equalTo: contentView.centerYAnchor)
            .leadingAnchor(equalTo: contentView.leadingAnchor, constant: BaseSegmentCell.textPadding)
            .trailingAnchor(equalTo: contentView.trailingAnchor, constant: -BaseSegmentCell.textPadding)
        
        verticalSeparatorView
            .topAnchor(equalTo: contentView.topAnchor)
            .bottomAnchor(equalTo: contentView.bottomAnchor)
            .trailingAnchor(equalTo: contentView.trailingAnchor)
            .widthAnchor(equalTo: 1)
    }
    
    override func setup(_ viewModel: ViewModel, isLastCell: Bool) {
        super.setup(viewModel, isLastCell: isLastCell)
        
        titleLabel.text = viewModel.title
    }
    
    override func configCell(_ viewModel: ViewModel, isLastCell: Bool) {
        setup(viewModel, isLastCell: isLastCell)
    }
}
