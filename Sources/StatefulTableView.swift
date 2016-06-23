//
//  StatefulTableView.swift
//  Demo
//
//  Created by Tim on 12/05/2016.
//  Copyright © 2016 timominous. All rights reserved.
//

import UIKit

/**
 Drop-in replacement for `UITableView` that supports pull-to-refresh, load-more, initial load, and empty states.
 */
public final class StatefulTableView: UIView {
  internal enum State {
    case Idle
    case InitialLoading
    case InitialLoadingTableView
    case EmptyOrInitialLoadError
    case LoadingFromPullToRefresh
    case LoadingMore

    var isLoading: Bool {
      switch self {
      case .InitialLoading: fallthrough
      case .InitialLoadingTableView: fallthrough
      case .LoadingFromPullToRefresh: fallthrough
      case .LoadingMore:
        return true
      default: return false
      }
    }

    var isInitialLoading: Bool {
      switch self {
      case .InitialLoading: fallthrough
      case .InitialLoadingTableView:
        return true
      default: return false
      }
    }
  }

  internal enum ViewMode {
    case Table
    case Static
  }

  /**
   Returns an object initialized from data in a given unarchiver.

   - Parameter aDecoder: An unarchiver object.

   - Returns: An initialized StatefulTableView object.
   */
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  /**
   Initializes and returns a newly allocatied view object with the specified frame rectangle.

   - Parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. this method uses the frame rectangle to set the center and bounds properties accordingly.

   - Returns: An initialized StatefulTableView object.
   */
  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  func commonInit() {
    addSubview(tableView)
    addSubview(staticContentView)

    refreshControl.addTarget(self,
      action: #selector(refreshControlValueChanged), forControlEvents: .ValueChanged)
    tableView.addSubview(refreshControl)
  }

  /**
   Lays out subviews.
   */
  override public func layoutSubviews() {
    super.layoutSubviews()
    tableView.frame = bounds
    staticContentView.frame = bounds
  }

  internal lazy var tableView = UITableView()

  /**
   An accessor to the contained `UITableView`.
   */
  public var innerTable: UITableView {
    return tableView
  }

  internal lazy var staticContentView: UIView = { [unowned self] in
    let view = UIView(frame: self.bounds)
    view.backgroundColor = .whiteColor()
    view.hidden = true
    return view
  }()

  internal lazy var refreshControl = UIRefreshControl()

  // MARK: - Properties

  /**
   Enables the user to pull down on the tableView to initiate a refresh
   */
  public var canPullToRefresh = false

  /**
   Enables the user to control whether to trigger loading of more objects or not
   */
  public var canLoadMore = false

  /**
   Distance from the bottom  of the tableView's vertical content offset where load more will be triggered
   */
  public var loadMoreTriggerThreshold: CGFloat = 64

  internal var loadMoreViewIsErrorView = false
  internal var lastLoadMoreError: NSError?
  internal var watchForLoadMore = false

  internal var state: State = .Idle

  internal var viewMode: ViewMode = .Table {
    didSet {
      let hidden = viewMode == .Table

      guard staticContentView.hidden != hidden else { return }
      staticContentView.hidden = hidden
    }
  }

  // MARK: - Stateful Delegate

  /**
   The object that acts as the stateful delegate of the table view.

   - Discussion: The stateful delegate must adopt the `StatefulTableDelegate` protocol. The stateful delegate is not retained.
   */
  weak public var statefulDelegate: StatefulTableDelegate?

}