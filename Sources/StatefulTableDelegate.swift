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

 - parameter isEmpty:       Describes if the table is empty.
 - parameter errorOrNil:    Describes the error received from loading. May be nil.
 */
public typealias InitialLoadCompletion = (_ isEmpty: Bool, _ errorOrNil: NSError?) -> Void

/**
 A closure declaration describing if the table can load more, received an error, and should show an error view.

 - parameter canLoadMore:   Describes if the table can loa dmore data.
 - parameter errorOrNil:    Describes the error received from loading. May be nil.
 - parameter showError:     Describes if an error view should be shown.
 */
public typealias LoadMoreCompletion = (_ canLoadMore: Bool, _ errorOrNil: NSError?, _ showError: Bool) -> Void

/**
 This protocol represents the loading behavior of the `StatefulTableView`.
 */
public protocol StatefulTableDelegate {
  
  // MARK: - Managing Loading
  
  /**
   This delegate method will be called when the tableView is triggered to load data initially.

   - parameter tableView:     The tableView calling the method.
   - parameter completion:    The completion handler describing if the table is empty
                              and if there is an error.
   */
  func statefulTable(_ tableView: StatefulTableView,
                     initialLoadCompletion completion: @escaping InitialLoadCompletion)

  /**
   This delegate method will be called when the user pulls down to refresh.

   - parameter tableView:     The tableView calling the method.
   - parameter completion:    The completion handler describing if the table is empty
                              and if there is an error.
   */
  func statefulTable(_ tableView: StatefulTableView,
                     pullToRefreshCompletion completion: @escaping InitialLoadCompletion)

  /**
   This delegate method will be called when the user scrolls to load more.

   - parameter tableView:     The tableView calling the method.
   - parameter completion:    The completion handler describing if the table can load more,
                              has an error, and should show an error view.
   */
  func statefulTable(_ tableView: StatefulTableView,
                     loadMoreCompletion completion: @escaping LoadMoreCompletion)

  // MARK: - Using Custom Views (Optional)

  /**
   This delegate method will be called when the tableView is in need of a view to show when
   it is loading data initially.

   - parameter tableView:     The tableView calling the method.
   - parameter defaultView:   The default view is a UIActivityIndicatorView,
                              which you can freely customize or return as is;
                              or you may opt to return a UIView subclass of your own instead.
   
   
   - returns: An optional view to show.
   */
  
  func statefulTable(_ tableView: StatefulTableView,
                     viewForInitialLoad defaultView: UIActivityIndicatorView) -> UIView?

  /**
   This delegate method will be called when the tableView is in need of a view to show when
   it's done loading initially and no data/an error was found.

   - parameter tableView:     The tableView calling the method.
   - parameter errorOrNil:    The optional error found.
   - parameter errorView:     The default view which you can customize, or return as is.

   - returns: An optional view to show.
   */
  func statefulTable(_ tableView: StatefulTableView,
                     initialLoadWithError errorOrNil: NSError?,
                     errorView: InitialLoadErrorView) -> UIView?

  /**
   This delegate method will be called when the tableView failed to load more data.

   - parameter tableView:     The tableView calling the method.
   - parameter errorOrNil:    The optional error found.
   - parameter errorView:     The default view which you can customize, or return as is.

   - returns: An optional view to show.
   */
  func statefulTable(_ tableView: StatefulTableView,
                     loadMoreWithError: NSError?,
                     errorView: LoadMoreErrorView) -> UIView?
}
// MARK: Delegate Optionality
public extension StatefulTableDelegate {
  
  func statefulTable(_ tableView: StatefulTableView,
                     viewForInitialLoad defaultView: UIActivityIndicatorView) -> UIView? {
    return defaultView
  }
  
  func statefulTable(_ tableView: StatefulTableView,
                     initialLoadWithError errorOrNil: NSError?,
                     errorView: InitialLoadErrorView) -> UIView? {
    return errorView
  }
  
  func statefulTable(_ tableView: StatefulTableView,
                     loadMoreWithError: NSError?,
                     errorView: LoadMoreErrorView) -> UIView? {
    return errorView
  }
}
