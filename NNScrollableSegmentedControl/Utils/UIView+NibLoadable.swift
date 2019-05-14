//
//  UIView+NibLoadable.swift
//  DevKit
//
//  Created by Nang Nguyen on 4/17/19.
//

import UIKit

extension NibLoadable where Self: UIView {
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
    
    static func loadFromNib(bundle: Bundle = .main) -> Self {
        guard let view = bundle.loadNibNamed(nibName, owner: nil, options: nil)?.first as? Self
            else { fatalError("Impossible to load \(Self.nibName)") }
        return view
    }
}

extension UICollectionReusableView: NibLoadable { }
