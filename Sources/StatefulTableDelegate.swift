//
//  StatefulTableDelegate.swift
//  Demo
//
//  Created by Tim on 12/05/2016.
//  Copyright © 2016 timominous. All rights reserved.
//

import UIKit

typealias InitialLoadCompletionHandler = (tableIsEmpty: Bool, errorOrNil: NSError?) -> Void
typealias LoadMoreCompletionHandler = (canLoadMore: Bool, errorOrNil: NSError?, showErrorView: Bool) -> Void

@objc protocol StatefulTableDelegate {
  func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: InitialLoadCompletionHandler)
  func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: InitialLoadCompletionHandler)
  func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: LoadMoreCompletionHandler)

  func statefulTableViewViewForInitialLoad(tvc: StatefulTableView) -> UIView?
  func statefulTableViewView(tvc: StatefulTableView, forInitialLoadError: NSError?) -> UIView?
  func statefulTableViewView(tvc: StatefulTableView, forLoadMoreError: NSError?) -> UIView?
}