//
//  UICollectionView+ReusableView.swift
//  DevKit
//
//  Created by Nang Nguyen on 1/28/19.
//

import UIKit

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_ option: RegisterCellOption<T>) {
        switch option {
        case .class(let cellType):
            register(cellType, forCellWithReuseIdentifier: cellType.reuseIdentifier)
        case .nib(let cellType):
            register(cellType.nib, forCellWithReuseIdentifier: cellType.reuseIdentifier)
        }
    }
    
    func register<T: UICollectionReusableView>(_ option: RegisterCellOption<T>, forSupplementaryViewOfKind elementKind: String) {
        switch option {
        case .class(let cellType):
            register(cellType, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: cellType.reuseIdentifier)
        case .nib(let cellType):
            register(cellType.nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: cellType.reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T? {
        
        return dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(_ viewType: T.Type, ofKind kind: String, for indexPath: IndexPath) -> T? {
        
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: viewType.reuseIdentifier, for: indexPath) as? T
    }
}
