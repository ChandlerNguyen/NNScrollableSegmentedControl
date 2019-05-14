//
//  BaseSegmentCollectionViewCell.swift
//  NNScrollableSegmentedControl
//
//  Created by Nang Nguyen on 5/13/19.
//

import UIKit

class BaseSegmentCollectionViewCell: UICollectionViewCell {
    
    static let textPadding:CGFloat = 8.0
    static let imageToTextMargin:CGFloat = 14.0
    static let imageSize:CGFloat = 14.0
    static let defaultFont = UIFont.systemFont(ofSize: 14)
    static let defaultTextColor = UIColor.darkGray
    static let underlineHeight: CGFloat = 3.0
    
    var viewModel: ViewModel? {
        didSet {
            if let viewModel = self.viewModel {
                self.configCell(viewModel)
            }
        }
    }
    
    public var contentColor: UIColor?
    public var selectedContentColor: UIColor?
    
    var normalAttributedTitle:NSAttributedString?
    var highlightedAttributedTitle:NSAttributedString?
    var selectedAttributedTitle:NSAttributedString?
    
    lazy var underlineView: UIView = {
        let underlineView = UIView()
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.backgroundColor = tintColor
        underlineView.isHidden = !isSelected
        return underlineView
    }()
    
    var showUnderline: Bool = true {
        didSet {
            if showUnderline == false {
                underlineView.backgroundColor = .clear
            } else {
                underlineView.backgroundColor = tintColor
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            underlineView.isHidden = !isSelected
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            underlineView.isHidden = !isHighlighted && !isSelected
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            underlineView.backgroundColor = tintColor
        }
    }
    
    func setup(_ viewModel: ViewModel) {
        self.normalAttributedTitle = viewModel.normalAttributedTitle
        self.highlightedAttributedTitle = viewModel.highlightedAttributedTitle
        self.selectedAttributedTitle = viewModel.selectedAttributedTitle
        
    }
    
    func configCell(_ viewModel: ViewModel) {
        fatalError("\(#function) must be implemented by the subclass!!!")
    }
}

extension BaseSegmentCollectionViewCell {
    
    class ViewModel {
        var title:String?
        var normalAttributedTitle:NSAttributedString?
        var highlightedAttributedTitle:NSAttributedString?
        var selectedAttributedTitle:NSAttributedString?
        var image:UIImage?
    }
    
}
