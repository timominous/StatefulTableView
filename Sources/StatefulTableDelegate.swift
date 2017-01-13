//
//  StatefulTableDelegate.swift
//  Demo
//
//  Created by Tim on 12/05/2016.
//  Copyright © 2016 timominous. All rights reserved.
//

import UIKit

/**
 A closure declaration describing if the table is empty and has an optional error.

 - parameter tableIsEmpty: Describes if the table is empty.
 - parameter errorOrNil:   Describes the error received from loading. May be nil.
 */
public typealias InitialLoadCompletionHandler = (_ isTableEmpty: Bool, _ errorOrNil: NSError?) -> Void

/**
 A closure declaration describing if the table can load more, received an error, and should show an error view.

 - parameter canLoadMore:   Describes if the table can loa dmore data.
 - parameter errorOrNil:    Describes the error received from loading. May be nil.
 - parameter showErrorView: Describes if an error view should be shown.
 */
public typealias LoadMoreCompletionHandler = (_ canLoadMore: Bool, _ errorOrNil: NSError?, _ showErrorView: Bool) -> Void

/**
 This protocol represents the loading behavior of the `StatefulTableView`.
 */
@objc public protocol StatefulTableDelegate: class {
  // MARK: - Managing Loading

  /**
   This delegate method will be called when the tableView is triggered to load data initially.

   - parameter tvc:     The tableView calling the method.
   - parameter handler: The completion handler describing if the table is empty and if there is an error.
   */
  func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler)

  /**
   This delegate method will be called when the user pulls down to refresh.

   - parameter tvc:     The tableView calling the method.
   - parameter handler: The completion handler describing if the table is empty and if there is an error.
   */
  func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler)

  /**
   This delegate method will be called when the user scrolls to load more.

   - parameter tvc:     The tableView calling the method.
   - parameter handler: The completion handler describing if the table can load more, has an error, and should show an error view.
   */
  func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler)

  // MARK: - Using Custom Views

  /**
   This delegate method will be called when the tableView is in need of a view to show when it is loading data initially.

   - parameter tvc: The tableView calling the method.

   - returns: An optional view to show.
   */
  @objc optional func statefulTableViewViewForInitialLoad(tvc: StatefulTableView) -> UIView?

  /**
   This delegate method will be called when the tableView is in need of a view to show when it's done loading initially and no data/an error was found.

   - parameter tvc:                 The tableView calling the method.
   - parameter forInitialLoadError: The optional error found.

   - returns: An optional view to show.
   */
  @objc optional func statefulTableViewInitialErrorView(tvc: StatefulTableView, forInitialLoadError: NSError?) -> UIView?

  /**
   This delegate method will be called when the tableView failed to load more data.

   - parameter tvc:              The tableView calling the method.
   - parameter forLoadMoreError: The optional error found.

   - returns: An optional view to show.
   */
  @objc optional func statefulTableViewLoadMoreErrorView(tvc: StatefulTableView, forLoadMoreError: NSError?) -> UIView?
}
