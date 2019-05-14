//
//  UIView+ReusableView.swift
//  DevKit
//
//  Created by Nang Nguyen on 1/28/19.
//

import UIKit

extension ReusableView where Self: UIView {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: ReusableView { }
