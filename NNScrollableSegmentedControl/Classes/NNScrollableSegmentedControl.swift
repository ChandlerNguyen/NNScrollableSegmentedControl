//
//  NNScrollableSegmentedControl.swift
//  NNScrollableSegmentedControl
//
//  Created by Nang Nguyen on 5/13/19.
//

import UIKit

public class NNScrollableSegmentedControl: UIControl {
    public enum Style {
        case textOnly
        case imageOnly
        case imageOnTop
        case imageOnLeft
    }
    
    private var longestTextWidth:CGFloat = 10
    private var normalAttributes:[NSAttributedString.Key : Any]?
    private var highlightedAttributes:[NSAttributedString.Key : Any]?
    private var selectedAttributes:[NSAttributedString.Key : Any]?
    private var titleAttributes:[UInt: [NSAttributedString.Key : Any]] = [UInt: [NSAttributedString.Key : Any]]()
    
    lazy private var backgroundEffectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: blur)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.contentView.backgroundColor = UIColor(white: 0.97, alpha: 0.5)
        return visualEffectView
    }()
    
    lazy private var backgroundColorView: UIView = {
        let view = UIView()
        view.alpha = 0.85
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    public var valueChanged: ((Int) -> Void)?
    
    // Set this property to -1 to turn of the current selection
    public var selectedSegmentIndex: Int = -1 {
        didSet {
            if let dataSource = self.dataSource {
                if selectedSegmentIndex < -1 {
                    selectedSegmentIndex = -1
                } else if selectedSegmentIndex > dataSource.numberOfSegments - 1 {
                    selectedSegmentIndex = dataSource.numberOfSegments - 1
                }
                
                if selectedSegmentIndex >= 0 {
                    var scrollPossition:UICollectionView.ScrollPosition = .bottom
                    let indexPath = IndexPath(item: selectedSegmentIndex, section: 0)
                    if let atribs = collectionView.layoutAttributesForItem(at: indexPath) {
                        let frame = atribs.frame
                        if frame.origin.x < collectionView.contentOffset.x {
                            scrollPossition = .left
                        } else if frame.origin.x + frame.size.width > (collectionView.frame.size.width + collectionView.contentOffset.x) {
                            scrollPossition = .right
                        }
                    }
                    
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: scrollPossition)
                } else {
                    if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                        collectionView.deselectItem(at: indexPath, animated: true)
                    }
                }
                
                if oldValue != selectedSegmentIndex {
                    self.sendActions(for: .valueChanged)
                }
            }
        }
    }
    
    public var style: Style = .textOnly {
        didSet {
            if oldValue != style {
                let indexPath = collectionView.indexPathsForSelectedItems?.last
                
                collectionView.reloadData()
                
                if indexPath != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                        self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
                    })
                }
            }
        }
    }
    
    public var underlineSelected: Bool = true {
        didSet {
            reloadSegments()
        }
    }
    
    override public var tintColor: UIColor! {
        didSet {
            collectionView.tintColor = tintColor
            reloadSegments()
        }
    }
    
    public var contentColor: UIColor? {
        didSet {
            reloadSegments()
        }
    }
    
    public var selectedContentColor: UIColor? {
        didSet {
            reloadSegments()
        }
    }
    
    public var fixedWidth: Bool = true {
        didSet {
            if oldValue != fixedWidth {
                reloadSegments()
            }
        }
    }
    
    lazy var dataSource: SegmentControlDataSource? = {
        let dataSource = SegmentControlDataSource(collectionView: collectionView, cellClassBlock: { [weak self] (indexPath, object) -> AnyClass? in
            guard let style = self?.style else {
                return nil
            }
            switch style {
            case .textOnly:
                return TextOnlySegmentCollectionViewCell.self
            case .imageOnly:
                return ImageOnlySegmentCollectionViewCell.self
            case .imageOnTop:
                return ImageOnTopSegmentCollectionViewCell.self
            case .imageOnLeft:
                return ImageOnLeftSegmentCollectionViewCell.self
            }
        })
        
        dataSource.itemSize = ({ [weak self] (_,_,item) in
            let obj = item as! BaseSegmentCollectionViewCell.ViewModel
            return self?.segmentSize(obj) ?? .zero
        })
        
        dataSource.didSelectItem = ({ [weak self](_, indexPath, _) in
            self!.selectedSegmentIndex = indexPath.item
        })
        
        dataSource.willDisplayItem = ({ [weak self] (cell) in
            var label:UILabel?
            if let _cell = cell as? TextOnlySegmentCollectionViewCell {
                label = _cell.titleLabel
            } else if let _cell = cell as? ImageOnTopSegmentCollectionViewCell {
                label = _cell.titleLabel
            } else if let _cell = cell as? ImageOnLeftSegmentCollectionViewCell {
                label = _cell.titleLabel
            } else {
                label = nil
            }
            
            if let titleLabel = label {
                let data = (cell as! BaseSegmentCollectionViewCell).viewModel!
                if cell.isHighlighted && data.highlightedAttributedTitle != nil {
                    titleLabel.attributedText = data.highlightedAttributedTitle!
                } else if cell.isSelected && data.selectedAttributedTitle != nil {
                    titleLabel.attributedText = data.selectedAttributedTitle!
                } else {
                    if data.normalAttributedTitle != nil {
                        titleLabel.attributedText = data.normalAttributedTitle!
                    }
                }
            }
        })
        
        dataSource.cellDecorator = ({ [weak self] (cell) in
            
            if let `self` = self {
                let segmentCell: BaseSegmentCollectionViewCell
                switch self.style {
                case .textOnly:
                    segmentCell = cell as! TextOnlySegmentCollectionViewCell
                case .imageOnly:
                    segmentCell = cell as! ImageOnlySegmentCollectionViewCell
                case .imageOnLeft:
                    segmentCell = cell as! ImageOnLeftSegmentCollectionViewCell
                case .imageOnTop:
                    segmentCell = cell as! ImageOnTopSegmentCollectionViewCell
                }
                segmentCell.tintColor = self.tintColor
                segmentCell.contentColor = self.contentColor
                segmentCell.selectedContentColor = self.selectedContentColor
                segmentCell.showUnderline = self.underlineSelected
            }
            
        })
        
        return dataSource
    }()
    
    public var numberOfSegments: Int {
        get {
            return dataSource?.viewModels.count ?? 0
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(titles: [String]) {
        super.init(frame: .zero)
        
        setupViewHierarchy()
        setupConstraints()
        
        var segments: [BaseSegmentCollectionViewCell.ViewModel] = [];
        for title in titles {
            _ = calculateLongestTextWidth(text: title)
            let segmentData = NNScrollableSegmentedControl.makeSegmentItem(withTitle: title)
            segments.append(segmentData)
        }
        dataSource?.viewModels = segments
        self.addTarget(self, action: #selector(segmentSelected(sender:)), for: .valueChanged)
    }
    
    public init(segments: [(title:String, image: UIImage?)]) {
        super.init(frame: .zero)
        
        setupViewHierarchy()
        setupConstraints()
        
        var items: [BaseSegmentCollectionViewCell.ViewModel] = [];
        for item in segments {
            _ = calculateLongestTextWidth(text: item.title)
            let segmentData = NNScrollableSegmentedControl.makeSegmentItem(withTitle: item.title, image: item.image)
            items.append(segmentData)
        }
        dataSource?.viewModels = items
        self.addTarget(self, action: #selector(segmentSelected(sender:)), for: .valueChanged)
    }
    
    @objc private func segmentSelected(sender: NNScrollableSegmentedControl) {
        valueChanged?(sender.selectedSegmentIndex)
    }
    
    private func setupViewHierarchy() {
        addSubview(backgroundEffectView)
        backgroundEffectView.contentView.addSubview(backgroundColorView)
        backgroundEffectView.contentView.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        backgroundEffectView
            .leadingAnchor(equalTo: self.leadingAnchor)
            .topAnchor(equalTo: self.topAnchor)
            .trailingAnchor(equalTo: self.trailingAnchor)
            .bottomAnchor(equalTo: self.bottomAnchor)
        
        backgroundColorView
            .topAnchor(equalTo: backgroundEffectView.topAnchor)
            .bottomAnchor(equalTo: backgroundEffectView.bottomAnchor)
            .trailingAnchor(equalTo: backgroundEffectView.trailingAnchor)
            .leadingAnchor(equalTo: backgroundEffectView.leadingAnchor)
        
        collectionView
            .topAnchor(equalTo: backgroundEffectView.topAnchor)
            .bottomAnchor(equalTo: backgroundEffectView.bottomAnchor)
            .trailingAnchor(equalTo: backgroundEffectView.trailingAnchor)
            .leadingAnchor(equalTo: backgroundEffectView.leadingAnchor)
        
    }
    
    private func segmentSize(_ segmentItem: BaseSegmentCollectionViewCell.ViewModel) -> CGSize {
        var itemSize: CGSize = .zero
        var imageWidth: CGFloat = 0.0
        if style == .imageOnLeft {
            imageWidth = BaseSegmentCollectionViewCell.imageSize + BaseSegmentCollectionViewCell.imageToTextMargin * 2
        }
        if fixedWidth {
            itemSize = CGSize(width: longestTextWidth + imageWidth, height: frame.size.height)
        } else {
            if segmentItem.image == nil {
                imageWidth = 0
            }
            itemSize = CGSize(width: calculateTextWidth(text: segmentItem.title!) + imageWidth, height: frame.size.height)
        }
        return itemSize
    }
    
    private func calculateSizeText(text: String) -> CGSize {
        let fontAttributes:[NSAttributedString.Key:Any]
        if normalAttributes != nil {
            fontAttributes = normalAttributes!
        } else if highlightedAttributes != nil {
            fontAttributes = highlightedAttributes!
        } else if selectedAttributes != nil {
            fontAttributes = selectedAttributes!
        } else {
            fontAttributes =  [NSAttributedString.Key.font: BaseSegmentCollectionViewCell.defaultFont]
        }
        
        return (text as NSString).size(withAttributes: fontAttributes)
    }
    
    private func calculateTextWidth(text: String) -> CGFloat {
        let size = calculateSizeText(text: text)
        return 2.0 + size.width + BaseSegmentCollectionViewCell.textPadding * 2
    }
    
    private func calculateLongestTextWidth(text:String) {
        let newLongestTextWidth = calculateTextWidth(text: text)
        if newLongestTextWidth > longestTextWidth {
            longestTextWidth = newLongestTextWidth
        }
    }
    
    private func reloadSegments() {
        collectionView.reloadData()
        if selectedSegmentIndex >= 0 {
            let indexPath = IndexPath(item: selectedSegmentIndex, section: 0)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
        }
    }
    
    private func configureAttributedTitlesForSegment(_ segmentItem: BaseSegmentCollectionViewCell.ViewModel) {
        segmentItem.normalAttributedTitle = nil
        segmentItem.highlightedAttributedTitle = nil
        segmentItem.selectedAttributedTitle = nil
        
        if let title = segmentItem.title {
            if normalAttributes != nil {
                segmentItem.normalAttributedTitle = NSAttributedString(string: title, attributes: normalAttributes!)
            }
            
            if highlightedAttributes != nil {
                segmentItem.highlightedAttributedTitle = NSAttributedString(string: title, attributes: highlightedAttributes!)
            } else {
                if selectedAttributes != nil {
                    segmentItem.highlightedAttributedTitle = NSAttributedString(string: title, attributes: selectedAttributes!)
                } else {
                    if normalAttributes != nil {
                        segmentItem.highlightedAttributedTitle = NSAttributedString(string: title, attributes: normalAttributes!)
                    }
                }
            }
            
            if selectedAttributes != nil {
                segmentItem.selectedAttributedTitle = NSAttributedString(string: title, attributes: selectedAttributes!)
            } else {
                if highlightedAttributes != nil {
                    segmentItem.selectedAttributedTitle = NSAttributedString(string: title, attributes: highlightedAttributes!)
                } else {
                    if normalAttributes != nil {
                        segmentItem.selectedAttributedTitle = NSAttributedString(string: title, attributes: normalAttributes!)
                    }
                }
            }
        }
    }
    
    // MARK: Manage segments
    public func insertSegment(withTitle title: String, at index: Int) {
        if let dataSource = self.dataSource {
            _ = calculateLongestTextWidth(text: title)
            let segment = NNScrollableSegmentedControl.makeSegmentItem(withTitle: title)
            dataSource.viewModels.insert(segment, at: index)
        }
    }
    
    public func insertSegment(withTitle title: String?, image: UIImage?, at index: Int) {
        if let dataSource = self.dataSource {
            if let str = title {
                _ = calculateLongestTextWidth(text: str)
            }
            let segment = NNScrollableSegmentedControl.makeSegmentItem(withTitle: title, image: image)
            dataSource.viewModels.insert(segment, at: index)
        }
    }
    
    public func removeSegment(at index: Int) {
        if let dataSource = self.dataSource {
            dataSource.viewModels.remove(at: index)
            if(selectedSegmentIndex == index) {
                selectedSegmentIndex = selectedSegmentIndex - 1
            } else if(selectedSegmentIndex > (dataSource.numberOfSegments)) {
                selectedSegmentIndex = -1
            }
        }
    }
    
    public func setAttributedTitle(_ attributes: [NSAttributedString.Key : Any]?, for state: UIControl.State) {
        if let dataSource = self.dataSource {
            titleAttributes[state.rawValue] = attributes
            
            normalAttributes = titleAttributes[UIControl.State.normal.rawValue]
            highlightedAttributes = titleAttributes[UIControl.State.highlighted.rawValue]
            selectedAttributes = titleAttributes[UIControl.State.selected.rawValue]
            
            for idx in 0...dataSource.numberOfSegments-1 {
                let segmentItem = dataSource.viewModels[idx]
                configureAttributedTitlesForSegment(segmentItem)
                
                if let title = segmentItem.title {
                    _ = calculateLongestTextWidth(text: title)
                }
            }
            
            reloadSegments()
        }
    }
}

extension NNScrollableSegmentedControl {
    
    static func makeSegmentItem(withTitle title: String?) -> BaseSegmentCollectionViewCell.ViewModel {
        let segment = BaseSegmentCollectionViewCell.ViewModel()
        segment.title = title
        return segment
    }
    
    static func makeSegmentItem(withTitle title: String?, image: UIImage?) -> BaseSegmentCollectionViewCell.ViewModel {
        let segment = BaseSegmentCollectionViewCell.ViewModel()
        segment.title = title
        segment.image = image?.withRenderingMode(.alwaysTemplate)
        return segment
    }
}
