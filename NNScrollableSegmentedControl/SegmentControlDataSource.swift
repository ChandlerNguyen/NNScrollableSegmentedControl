//
//  CollectionViewDataSource.swift
//  NNScrollableSegmentedControl
//
//  Created by Nang Nguyen on 5/13/19.
//

import UIKit

typealias CellClassBlock = (_ indexPath: IndexPath, _ object: Any?) -> AnyClass?
class SegmentControlDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private weak var collectionView: UICollectionView?
    private var cellClassBlock: CellClassBlock?
    var viewModels: [BaseSegmentCollectionViewCell.ViewModel] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var didSelectItem: (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ object: Any) -> Void = {_,_,_ in}
    var itemSize: (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ object: Any) -> CGSize = {_,_,_ in CGSize(width: 0,height: 0)}
    var willDisplayItem: ((_ cell: UICollectionViewCell) -> Void)?
    var cellDecorator: ((_ cell: UICollectionViewCell) -> Void)?
    
    var numberOfSegments: Int {
        get {
            return viewModels.count
        }
    }
    
    private subscript(indexPath: IndexPath) -> Any? {
        return viewModels[indexPath.row]
    }
    
    init(collectionView: UICollectionView, cellClassBlock: @escaping CellClassBlock) {
        self.cellClassBlock = cellClassBlock
        self.collectionView = collectionView
        super.init()
        registerCells(in: collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    private func registerCells(in collectionView: UICollectionView) {
        collectionView.register(.class(TextOnlySegmentCollectionViewCell.self))
        collectionView.register(.class(ImageOnlySegmentCollectionViewCell.self))
        collectionView.register(.class(ImageOnTopSegmentCollectionViewCell.self))
        collectionView.register(.class(ImageOnLeftSegmentCollectionViewCell.self))
    }
    
    // MARK: UICollectionViewDataSource conforms
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let object = self.viewModels[indexPath.row]
        let cellClass = self.cellClassBlock?(indexPath, object) as! BaseSegmentCollectionViewCell.Type
        let cell = collectionView.dequeueReusableCell(cellClass.self, for: indexPath)!
        cell.viewModel = object
        
        cellDecorator?(cell)
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout conforms
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemSize = self.itemSize(collectionView, indexPath, self[indexPath]!)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout, itemSize == .zero {
            itemSize = layout.itemSize
        }
        return itemSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.willDisplayItem?(cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didSelectItem(collectionView,indexPath, self[indexPath]!)
    }
}
