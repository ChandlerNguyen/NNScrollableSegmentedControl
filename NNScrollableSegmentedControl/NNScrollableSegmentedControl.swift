//
//  NNScrollableSegmentedControl.swift
//  NNScrollableSegmentedControl
//
//  Created by Nang Nguyen on 5/13/19.
//

import UIKit

public class NNScrollableSegmentedControl: UIView {
    
    // MARK: Public properties
    public var animationDuration: CFTimeInterval = 0.3
    public var indicatorPosition: IndicatorPosition = .bottom
    public var indicatorColor: UIColor = .blue {
        didSet {
            if let indicatorLayer = self.indicatorLayer {
                indicatorLayer.removeFromSuperlayer()
                if indicatorColor != .clear {
                    layer.insertSublayer(indicatorLayer, below: layer)
                }
            }
        }
    }
    
    public var selectedBackgroundColor: UIColor = .cyan {
        didSet {
            if let selectedLayer = self.selectedLayer {
                selectedLayer.removeFromSuperlayer()
                if selectedBackgroundColor != .clear {
                    layer.insertSublayer(selectedLayer, below: collectionView.layer)
                }
            }
        }
    }
    public var valueDidChange: ((_ segmentedControl: NNScrollableSegmentedControl, _ selectedSegmentIndex: Int) -> Void)?
    
    // Set this property to -1 to turn of the current selection
    public var selectedSegmentIndex: Int = -1 {
        didSet {
            if oldValue != selectedSegmentIndex {
                reloadSegments()
                valueDidChange?(self,selectedSegmentIndex)
            }
        }
    }
    
    public var style: Style = .textOnly {
        didSet {
            if oldValue != style {
                reloadSegments()
            }
        }
    }
    
    public var segmentWidthStyle: SegmentWidthOption = .fixed(maxVisibleItems: 4) {
        didSet {
            reloadSegments()
        }
    }
    
    public var numberOfSegments: Int {
        get {
            return dataSource?.viewModels.count ?? 0
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
    
    // MARK: Private properties
    
    private var longestTextWidth:CGFloat = 10
    private var normalAttributes:[NSAttributedString.Key : Any]?
    private var highlightedAttributes:[NSAttributedString.Key : Any]?
    private var selectedAttributes:[NSAttributedString.Key : Any]?
    private var titleAttributes:[UInt: [NSAttributedString.Key : Any]] = [UInt: [NSAttributedString.Key : Any]]()
    
    private var isPerformingScrollAnimation = false
    
    lazy private var indicatorLayer: CAShapeLayer? = {
        let indicatorLayer = CAShapeLayer()
        
        indicatorLayer.fillColor = indicatorColor.cgColor
        indicatorLayer.strokeColor = indicatorColor.cgColor
        indicatorLayer.lineWidth = 5
        layer.insertSublayer(indicatorLayer, below: layer)
        
        return indicatorLayer
    }()
    
    lazy private var selectedLayer: CAShapeLayer? = {
        let selectedLayer = CAShapeLayer()
        selectedLayer.fillColor = selectedBackgroundColor.cgColor
        selectedLayer.strokeColor =  selectedBackgroundColor.cgColor
        selectedLayer.lineWidth = bounds.height
        layer.insertSublayer(selectedLayer, below: collectionView.layer)
        return selectedLayer
    }()
    
    
    lazy private var collectionView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = true
        
        return collectionView
    }()
    
    lazy private var dataSource: SegmentControlDataSource? = {
        let dataSource = SegmentControlDataSource(collectionView: collectionView, cellClassBlock: { [weak self] (indexPath, object) -> AnyClass? in
            guard let style = self?.style else {
                return nil
            }
            switch style {
            case .textOnly:
                return SegmentCellWithLabel.self
            case .imageOnly:
                return SegmentCellWithImage.self
            case .imageOverText:
                return SegmentCellWithImageOverLabel.self
            case .imageBeforeText:
                return SegmentCellWithImageBeforeLabel.self
            }
        })
        
        dataSource.itemSize = ({ [weak self] (_,indexPath,object) in
            return self?.segmentSize(object) ?? .zero
        })
        
        dataSource.didSelectItem = ({ [weak self](_, indexPath, _) in
            self!.selectedSegmentIndex = indexPath.item
        })
        
        dataSource.willDisplayItem = ({ [weak self] (cell,object) in
            var label:UILabel?
            if let _cell = cell as? SegmentCellWithLabel {
                label = _cell.titleLabel
            } else if let _cell = cell as? SegmentCellWithImageOverLabel {
                label = _cell.titleLabel
            } else if let _cell = cell as? SegmentCellWithImageBeforeLabel {
                label = _cell.titleLabel
            } else {
                label = nil
            }
            
            if let titleLabel = label {
                let data = object
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
        
        dataSource.cellDecorator = ({ [weak self] (cell,_) in
            
            if let `self` = self {
                let segmentCell: BaseSegmentCell
                switch self.style {
                case .textOnly:
                    segmentCell = cell as! SegmentCellWithLabel
                case .imageOnly:
                    segmentCell = cell as! SegmentCellWithImage
                case .imageBeforeText:
                    segmentCell = cell as! SegmentCellWithImageBeforeLabel
                case .imageOverText:
                    segmentCell = cell as! SegmentCellWithImageOverLabel
                }
                segmentCell.tintColor = self.tintColor
                segmentCell.contentColor = self.contentColor
                segmentCell.selectedContentColor = self.selectedContentColor
            }
            
        })
        
        dataSource.didScroll = ({ [weak self] (_) in
            if let `self` = self, !self.isPerformingScrollAnimation {
                let item = self.itemInSuperView()
                if let indicatorLayer = self.indicatorLayer {
                    self.moveShapeLayer(
                        indicatorLayer,
                        startPoint: CGPoint(x: item.startX, y: self.indicatorPointY()),
                        endPoint: CGPoint(x: item.endX, y: self.indicatorPointY()),
                        animated: false
                    )
                }
                
                if let selectedLayer = self.selectedLayer {
                    self.moveShapeLayer(
                        selectedLayer,
                        startPoint: CGPoint(x: item.startX, y: self.bounds.midY),
                        endPoint: CGPoint(x: item.endX, y: self.bounds.midY),
                        animated: false
                    )
                }
            }
        })
        
        return dataSource
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViewHierarchy()
        setupConstraints()
    }
    
    public init(titles: [String]) {
        super.init(frame: .zero)
        
        setupViewHierarchy()
        setupConstraints()
        
        var segments: [BaseSegmentCell.ViewModel] = [];
        for title in titles {
            _ = calculateLongestTextWidth(text: title)
            let segmentData = NNScrollableSegmentedControl.makeSegmentItem(withTitle: title)
            segments.append(segmentData)
        }
        dataSource?.viewModels = segments
    }
    
    public init(segments: [(title:String, image: UIImage?)]) {
        super.init(frame: .zero)
        
        setupViewHierarchy()
        setupConstraints()
        
        var items: [BaseSegmentCell.ViewModel] = [];
        for item in segments {
            _ = calculateLongestTextWidth(text: item.title)
            let segmentData = NNScrollableSegmentedControl.makeSegmentItem(withTitle: item.title, image: item.image)
            items.append(segmentData)
        }
        dataSource?.viewModels = items
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        selectedLayer?.lineWidth = bounds.height
        reloadSegments()
    }
    
    private func setupViewHierarchy() {
        addSubview(collectionView)
    }
    
    private func setupConstraints() {
        collectionView
            .topAnchor(equalTo: self.topAnchor)
            .bottomAnchor(equalTo: self.bottomAnchor)
            .trailingAnchor(equalTo: self.trailingAnchor)
            .leadingAnchor(equalTo: self.leadingAnchor)
    }
    
    private func segmentSize(_ segmentItem: BaseSegmentCell.ViewModel) -> CGSize {
        var itemSize: CGSize = .zero
        var imageWidth: CGFloat = 0.0
        let cntSegmentItem = dataSource?.viewModels.count ?? 0
        if style == .imageBeforeText {
            imageWidth = BaseSegmentCell.imageSize + BaseSegmentCell.imageToTextMargin * 2
        }
        
        switch segmentWidthStyle {
        case .dynamic:
            if segmentItem.image == nil {
                imageWidth = 0
            }
            itemSize = CGSize(width: calculateTextWidth(text: segmentItem.title!) + imageWidth, height: frame.size.height)

        case .fixed(let maxVisibleItems):
            let collectionViewWidth = collectionView.frame.width
            let maxItems = maxVisibleItems > cntSegmentItem ? cntSegmentItem : maxVisibleItems
            let width = maxItems == 0 ? 0 : floor(collectionViewWidth / CGFloat(maxItems))
            itemSize = CGSize(width: width, height: frame.size.height)
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
            fontAttributes =  [NSAttributedString.Key.font: BaseSegmentCell.defaultFont]
        }
        
        return (text as NSString).size(withAttributes: fontAttributes)
    }
    
    private func calculateTextWidth(text: String) -> CGFloat {
        let size = calculateSizeText(text: text)
        return 2.0 + size.width + BaseSegmentCell.textPadding * 2
    }
    
    private func calculateLongestTextWidth(text:String) {
        let newLongestTextWidth = calculateTextWidth(text: text)
        if newLongestTextWidth > longestTextWidth {
            longestTextWidth = newLongestTextWidth
        }
    }
    
    private func reloadSegments() {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        guard selectedSegmentIndex != -1 else { return }
        scrollToItemAtContext()
        moveShapeLayerAtContext()
    }
    
    private func configureAttributedTitlesForSegment(_ segmentItem: BaseSegmentCell.ViewModel) {
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
    
    private func itemInSuperView(ratio: CGFloat = 1) -> ItemInSuperview {
        var collectionViewWidth: CGFloat = 0
        var cellWidth: CGFloat = 0
        var cellRect = CGRect.zero
        var shapeLayerWidth: CGFloat = 0
        
        if selectedSegmentIndex != -1 {
            collectionViewWidth = collectionView.frame.width
            cellWidth = segmentWidth(for: IndexPath(row: selectedSegmentIndex, section: 0))
            var x: CGFloat = 0
            
            switch segmentWidthStyle {
            case .fixed:
                x = floor(CGFloat(selectedSegmentIndex) * cellWidth - collectionView.contentOffset.x)
                
            case .dynamic:
                for i in 0..<selectedSegmentIndex {
                    x += segmentWidth(for: IndexPath(item: i, section: 0))
                }

                x -= collectionView.contentOffset.x
            }
            
            cellRect = CGRect(
                x: x,
                y: 0,
                width: cellWidth,
                height: collectionView.frame.height
            )
            
            shapeLayerWidth = floor(cellWidth * ratio)
        }
        
        return ItemInSuperview(
            collectionViewWidth: collectionViewWidth,
            cellFrameInSuperview: cellRect,
            shapeLayerWidth: shapeLayerWidth,
            startX: floor(cellRect.midX - (shapeLayerWidth / 2)),
            endX: floor(cellRect.midX + (shapeLayerWidth / 2))
        )
    }
    
    private func segmentWidth(for indexPath: IndexPath) -> CGFloat {
        var width: CGFloat = 0
        if let dataSource = self.dataSource, !dataSource.viewModels.isEmpty {
            let item = dataSource.viewModels[indexPath.row]
            width = segmentSize(item).width
        }
        
        return width
    }
    
    private func scrollToItemAtContext() {
        guard selectedSegmentIndex != -1 else {
            return
        }
        
        let item = itemInSuperView()
        collectionView.scrollRectToVisible(centerRect(for: item), animated: true)
    }
    
    private func moveShapeLayerAtContext() {
        if let dataSource = self.dataSource, !dataSource.viewModels.isEmpty {
            let itemWidth = dataSource.viewModels.enumerated().map { (index, _) -> CGFloat in
                return segmentWidth(for: IndexPath(item: index, section: 0))
            }
            
            let item = itemInSuperView()

            if let indicatorLayer = self.indicatorLayer {
                let points = Points(
                    item: item,
                    atIndex: selectedSegmentIndex,
                    allItemsCellWidth: itemWidth,
                    pointY: indicatorPointY()
                )
                let insetX = ((points.endPoint.x - points.startPoint.x) - (item.endX - item.startX))/2
                moveShapeLayer(
                    indicatorLayer,
                    startPoint: CGPoint(x: points.startPoint.x + insetX, y: points.startPoint.y),
                    endPoint: CGPoint(x: points.endPoint.x - insetX, y: points.endPoint.y),
                    animated: true
                )
            }
            
            if let selectedLayer = selectedLayer {
                let points = Points(
                    item: item,
                    atIndex: selectedSegmentIndex,
                    allItemsCellWidth: itemWidth,
                    pointY: bounds.midY
                )
                
                moveShapeLayer(
                    selectedLayer,
                    startPoint: points.startPoint,
                    endPoint: points.endPoint,
                    animated: true
                )
            }
        }
    }
    
    private func indicatorPointY() -> CGFloat {
        var indicatorPointY: CGFloat = 0
        let indicatorOptionHeight: CGFloat = 5
        
        switch indicatorPosition {
        case .top:
            indicatorPointY = (indicatorOptionHeight / 2)
        case .bottom:
            indicatorPointY = frame.height - (indicatorOptionHeight / 2)
        }
        
//        guard let horizontalSeparatorOptions = segmentioOptions.horizontalSeparatorOptions else {
//            return indicatorPointY
//        }
//
//        let separatorHeight = horizontalSeparatorOptions.height
//        let isIndicatorTop = indicatorOptions.type == .top
//
//        switch horizontalSeparatorOptions.type {
//        case .none:
//            break
//        case .top:
//            indicatorPointY = isIndicatorTop ? indicatorPointY + separatorHeight : indicatorPointY
//        case .bottom:
//            indicatorPointY = isIndicatorTop ? indicatorPointY : indicatorPointY - separatorHeight
//        case .topAndBottom:
//            indicatorPointY = isIndicatorTop ? indicatorPointY + separatorHeight : indicatorPointY - separatorHeight
//        }
        
        return indicatorPointY
    }
    
    private func centerRect(for item: ItemInSuperview) -> CGRect {
        
        let item = itemInSuperView()
        var centerRect = item.cellFrameInSuperview

        if (item.startX + collectionView.contentOffset.x) - (item.collectionViewWidth - centerRect.width) / 2 < 0 {
            centerRect.origin.x = 0
            let widthToAdd = item.collectionViewWidth - centerRect.width
            centerRect.size.width += widthToAdd
        } else if collectionView.contentSize.width - item.endX < (item.collectionViewWidth - centerRect.width) / 2 {
            centerRect.origin.x = collectionView.contentSize.width - item.collectionViewWidth
            centerRect.size.width = item.collectionViewWidth
        } else {
            centerRect.origin.x = item.startX - (item.collectionViewWidth - centerRect.width) / 2
                + collectionView.contentOffset.x
            centerRect.size.width = item.collectionViewWidth
        }

        return centerRect
    }
    
    private func moveShapeLayer(_ shapeLayer: CAShapeLayer,
                                startPoint: CGPoint,
                                endPoint: CGPoint,
                                animated: Bool = false) {
        
        var endPointWithVerticalSeparator = endPoint
        let isLastItem = selectedSegmentIndex + 1 == dataSource?.numberOfSegments
        endPointWithVerticalSeparator.x = endPoint.x - (isLastItem ? 0 : 1)
        
        let shapeLayerPath = UIBezierPath()
        shapeLayerPath.move(to: startPoint)
        shapeLayerPath.addLine(to: endPointWithVerticalSeparator)
        
        if animated == true {
            isPerformingScrollAnimation = true
            isUserInteractionEnabled = false
            
            CATransaction.begin()
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = shapeLayer.path
            animation.toValue = shapeLayerPath.cgPath
            animation.duration = animationDuration
            CATransaction.setCompletionBlock() {
                self.isPerformingScrollAnimation = false
                self.isUserInteractionEnabled = true
            }
            shapeLayer.add(animation, forKey: "path")
            CATransaction.commit()
        }
        
        shapeLayer.path = shapeLayerPath.cgPath
    }
    
    // MARK: Manage segments
    public func insertSegment(withTitle title: String, at index: Int) {
        if let dataSource = self.dataSource {
            _ = calculateLongestTextWidth(text: title)
            let segment = NNScrollableSegmentedControl.makeSegmentItem(withTitle: title)
            dataSource.viewModels.insert(segment, at: index)
            scrollToItemAtContext()
            moveShapeLayerAtContext()
        }
    }
    
    public func insertSegment(withTitle title: String?, image: UIImage?, at index: Int) {
        if let dataSource = self.dataSource {
            if let str = title {
                _ = calculateLongestTextWidth(text: str)
            }
            let segment = NNScrollableSegmentedControl.makeSegmentItem(withTitle: title, image: image)
            dataSource.viewModels.insert(segment, at: index)
            scrollToItemAtContext()
            moveShapeLayerAtContext()
        }
    }
    
    public func removeSegment(at index: Int) {
        if let dataSource = self.dataSource {
            dataSource.viewModels.remove(at: index)
            if(selectedSegmentIndex == index) {
                selectedSegmentIndex = selectedSegmentIndex - 1
                scrollToItemAtContext()
                moveShapeLayerAtContext()
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
    
    internal struct Points {
        var startPoint: CGPoint
        var endPoint: CGPoint
        
        init(item: ItemInSuperview, atIndex index: Int, allItemsCellWidth: [CGFloat], pointY: CGFloat) {
            let cellWidth = item.cellFrameInSuperview.width
            var startX = item.startX
            var endX = item.endX
            var spaceBefore: CGFloat = 0
            var spaceAfter: CGFloat = 0
            var i = 0
            allItemsCellWidth.forEach { width in
                if i < index { spaceBefore += width }
                if i > index { spaceAfter += width }
                i += 1
            }
            // Cell will try to position itself in the middle, unless it can't because
            // the collection view has reached the beginning or end
            startX = (item.collectionViewWidth / 2) - (cellWidth / 2 )
            if spaceBefore < (item.collectionViewWidth - cellWidth) / 2 {
                startX = spaceBefore
            }
            if spaceAfter < (item.collectionViewWidth - cellWidth) / 2 {
                startX = item.collectionViewWidth - spaceAfter - cellWidth
            }
            endX = startX + cellWidth
            
            startPoint = CGPoint(x: startX, y: pointY)
            endPoint = CGPoint(x: endX, y: pointY)
        }
    }
    
    internal struct ItemInSuperview {
        var collectionViewWidth: CGFloat
        var cellFrameInSuperview: CGRect
        var shapeLayerWidth: CGFloat
        var startX: CGFloat
        var endX: CGFloat
    }
    
    static func makeSegmentItem(withTitle title: String?) -> BaseSegmentCell.ViewModel {
        let segment = BaseSegmentCell.ViewModel()
        segment.title = title
        return segment
    }
    
    static func makeSegmentItem(withTitle title: String?, image: UIImage?) -> BaseSegmentCell.ViewModel {
        let segment = BaseSegmentCell.ViewModel()
        segment.title = title
        segment.image = image?.withRenderingMode(.alwaysTemplate)
        return segment
    }
    
}

// MARK: Public enums

extension NNScrollableSegmentedControl {
    public enum SegmentWidthOption {
        case dynamic
        case fixed(maxVisibleItems: Int)
    }
    
    public enum Style {
        case textOnly
        case imageOnly
        case imageOverText
        case imageBeforeText
    }
    
    public enum IndicatorPosition {
        case top
        case bottom
    }
}
