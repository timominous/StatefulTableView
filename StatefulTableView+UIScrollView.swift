//
//  StatefulTableView+UIScrollView.swift
//  Pods-Demo
//
//  Created by Tim on 19/11/2017.
//

import UIKit

extension StatefulTableView {
  
  /**
   The point which the origin of the content view is offset from the origin of the scroll view.
   
   - Discussion: Visit this [link](https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset) for more details
   */
  public var contentOffset: CGPoint {
    set { tableView.contentOffset = newValue }
    get { return tableView.contentOffset }
  }
  
  /**
   The size of the content view.
   
   - Discussion: Visit this [link](https://developer.apple.com/documentation/uikit/uiscrollview/1619399-contentsize) for more details
   */
  public var contentSize: CGSize {
    set { tableView.contentSize = newValue }
    get { return tableView.contentSize }
  }
  
  /**
   The custom distance that the content view is inset from the safe area or scroll view edges.
   
   - Discussion: Visit this [link](https://developer.apple.com/documentation/uikit/uiscrollview/1619406-contentinset) for more details
   */
  public var contentInset: UIEdgeInsets {
    set { tableView.contentInset = newValue }
    get { return tableView.contentInset }
  }
}
