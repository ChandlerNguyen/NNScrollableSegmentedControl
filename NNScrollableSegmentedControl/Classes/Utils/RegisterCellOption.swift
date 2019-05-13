//
//  Reusable.swift
//  DevKit
//
//  Created by Nang Nguyen on 4/18/19.
//

import UIKit

enum RegisterCellOption<CellType> {
    case `class`(_ cellType: CellType.Type)
    case nib(_ cellType: CellType.Type)
}
