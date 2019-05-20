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
    var viewModels: [BaseSegmentCell.ViewModel] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var didSelectItem: (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ object: BaseSegmentCell.ViewModel) -> Void = {_,_,_ in}
    var itemSize: (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ object: BaseSegmentCell.ViewModel) -> CGSize = {_,_,_ in CGSize(width: 0,height: 0)}
    var willDisplayItem: ((_ cell: UICollectionViewCell, _ object: BaseSegmentCell.ViewModel) -> Void)?
    var cellDecorator: ((_ cell: UICollectionViewCell, _ object: BaseSegmentCell.ViewModel) -> Void)?
    var didScroll:((_ scrollView: UIScrollView) -> Void)?
    
    var numberOfSegments: Int {
        get {
            return viewModels.count
        }
    }
    
    private subscript(indexPath: IndexPath) -> BaseSegmentCell.ViewModel? {
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
        collectionView.register(.class(SegmentCellWithLabel.self))
        collectionView.register(.class(SegmentCellWithImage.self))
        collectionView.register(.class(SegmentCellWithImageOverLabel.self))
        collectionView.register(.class(SegmentCellWithImageBeforeLabel.self))
    }
    
    // MARK: UICollectionViewDataSource conforms
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let object = self[indexPath]!
        let cellClass = self.cellClassBlock?(indexPath, object) as! BaseSegmentCell.Type
        let cell = collectionView.dequeueReusableCell(cellClass.self, for: indexPath)!
        cell.configCell(object, isLastCell: indexPath.row == viewModels.count - 1)
        cellDecorator?(cell, object)
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.willDisplayItem?(cell,self[indexPath]!)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didSelectItem(collectionView,indexPath, self[indexPath]!)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.didScroll?(scrollView)
    }
}
