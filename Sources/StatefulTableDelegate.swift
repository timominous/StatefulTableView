//
//  StatefulTableDelegate.swift
//  Demo
//
//  Created by Tim on 12/05/2016.
//  Copyright © 2016 timominous. All rights reserved.
//

import UIKit

public typealias InitialLoadCompletionHandler = (tableIsEmpty: Bool, errorOrNil: NSError?) -> Void
public typealias LoadMoreCompletionHandler = (canLoadMore: Bool, errorOrNil: NSError?, showErrorView: Bool) -> Void

public protocol StatefulTableDelegate {
  /**
   This delegate method will be called when the tableView is triggered to load data initially.

   - parameter tvc:     The tableView calling the method.
   - parameter handler: The completion handler describing if the table is empty and if there is an error.
   */
  func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: InitialLoadCompletionHandler)

  /**
   This delegate method will be called when the user pulls down to refresh.

   - parameter tvc:     The tableView calling the method.
   - parameter handler: The completion handler describing if the table is empty and if there is an error.
   */
  func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: InitialLoadCompletionHandler)

  /**
   This delegate method will be called when the user scrolls to load more.

   - parameter tvc:     The tableView calling the method.
   - parameter handler: The completion handler describing if the table can load more, has an error, and should show an error view.
   */
  func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: LoadMoreCompletionHandler)

  /// Views

  /**
   This delegate method will be called when the tableView is in need of a view to show when it is loading data initially.

   - parameter tvc: The tableView calling the method.

   - returns: An optional view to show. Defaults to built in view when nil.
   */
  func statefulTableViewViewForInitialLoad(tvc: StatefulTableView) -> UIView?

  /**
   This delegate method will be called when the tableView is in need of a view to show when it's done loading initially and no data/an error was found.

   - parameter tvc:                 The tableView calling the method.
   - parameter forInitialLoadError: The optional error found.

   - returns: An optional view to show. Defaults to built in view when nil.
   */
  func statefulTableViewView(tvc: StatefulTableView, forInitialLoadError: NSError?) -> UIView?

  /**
   This delegate method will be called when the tableView failed to load more data.

   - parameter tvc:              The tableView calling the method.
   - parameter forLoadMoreError: The optional error found.

   - returns: An optional view to show. Default to built in view when nil.
   */
  func statefulTableViewView(tvc: StatefulTableView, forLoadMoreError: NSError?) -> UIView?
}