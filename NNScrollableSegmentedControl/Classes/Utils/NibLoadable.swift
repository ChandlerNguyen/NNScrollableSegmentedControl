//
//  NibLoadable.swift
//  DevKit
//
//  Created by Nang Nguyen on 4/17/19.
//

import Foundation
import UIKit

protocol NibLoadable: class {
    static var nibName: String { get }
}

extension NibLoadable {
    public static var nibName: String {
        return String(describing: self).components(separatedBy: ".").first!
    }
}
