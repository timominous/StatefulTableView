//
//  CGRect+Extensions.swift
//  Demo
//
//  Created by Tim on 13/05/2016.
//  Copyright © 2016 timominous. All rights reserved.
//

import CoreGraphics

extension CGRect {
  mutating func centerInFrame(bounds: CGRect) {
    origin.x = (bounds.width - width) * 0.5
    origin.y = (bounds.height - height) * 0.5
  }
}