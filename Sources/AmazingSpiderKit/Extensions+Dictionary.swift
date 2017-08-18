//
//  Extensions+Dictionary.swift
//  AmazingSpiderKit
//
//  Created by 吴迪玮 on 2017/8/18.
//

import Foundation

extension Dictionary {
    public static func +=(lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach({ lhs[$0] = $1})
    }
}
