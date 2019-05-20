//
//  BaseSegmentCollectionViewCell.swift
//  NNScrollableSegmentedControl
//
//  Created by Nang Nguyen on 5/13/19.
//

import UIKit

class BaseSegmentCell: UICollectionViewCell {
    
    static let textPadding:CGFloat = 8.0
    static let imageToTextMargin:CGFloat = 14.0
    static let imageSize:CGFloat = 14.0
    static let defaultFont = UIFont.systemFont(ofSize: 14)
    static let defaultTextColor = UIColor.darkGray
    
    public var contentColor: UIColor?
    public var selectedContentColor: UIColor?
    
    var normalAttributedTitle:NSAttributedString?
    var highlightedAttributedTitle:NSAttributedString?
    var selectedAttributedTitle:NSAttributedString?
    
    private var verticalSeparatorLayer = CAShapeLayer()
    lazy var verticalSeparatorView: UIView = {
        let verticalSeparatorView = UIView()
        verticalSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        return verticalSeparatorView
    }()
    
    override func prepareForReuse() {
        verticalSeparatorLayer.removeFromSuperlayer()
        super.prepareForReuse()
    }
    
    func setup(_ viewModel: ViewModel, isLastCell: Bool) {
        self.normalAttributedTitle = viewModel.normalAttributedTitle
        self.highlightedAttributedTitle = viewModel.highlightedAttributedTitle
        self.selectedAttributedTitle = viewModel.selectedAttributedTitle
        if !isLastCell {
            setupVerticalSeparators()
        }
        
    }
    
    func configCell(_ viewModel: ViewModel, isLastCell: Bool) {
        fatalError("\(#function) must be implemented by the subclass!!!")
    }
    
    private func setupVerticalSeparators() {
        let verticalSeparatorOptionsColor = UIColor.gray
        let verticalSeparatorOptionsRatio = 1
        let heightWithRatio = bounds.height * CGFloat(verticalSeparatorOptionsRatio)
        let difference = (bounds.height - heightWithRatio) / 2
        
        let startY = difference
        let endY = bounds.height - difference
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: verticalSeparatorView.frame.width / 2, y: startY))
        path.addLine(to: CGPoint(x: verticalSeparatorView.frame.width / 2, y: endY))
        
        verticalSeparatorLayer.path = path.cgPath
        verticalSeparatorLayer.lineWidth = 1
        verticalSeparatorLayer.strokeColor = verticalSeparatorOptionsColor.cgColor
        verticalSeparatorLayer.fillColor = verticalSeparatorOptionsColor.cgColor
        
        verticalSeparatorView.layer.addSublayer(verticalSeparatorLayer)
    }
    
}

extension BaseSegmentCell {
    
    class ViewModel {
        var title:String?
        var image:UIImage?
        var normalAttributedTitle:NSAttributedString?
        var highlightedAttributedTitle:NSAttributedString?
        var selectedAttributedTitle:NSAttributedString?
    }
    
}
