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

  private enum ViewMode {
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

  private lazy var staticContentView: UIView = { [unowned self] in
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

  private var loadMoreViewIsErrorView = false
  private var lastLoadMoreError: NSError?
  private var watchForLoadMore = false

  internal var state: State = .Idle

  private var viewMode: ViewMode = .Table {
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

extension StatefulTableView {
  // MARK: - Initial load

  /**
   Triggers initial load of data programatically. Defaults to hiding the tableView.

   - returns: Boolean for success status.
   */
  public func triggerInitialLoad() -> Bool {
    return triggerInitialLoad(false)
  }

  /**
   Triggers initial load of data programatically.

   - parameter shouldShowTableView: Control if the container should show the tableView or not.

   - returns: Boolean for success status.
   */
  public func triggerInitialLoad(shouldShowTableView: Bool) -> Bool {
    guard !state.isLoading else { return false }

    if shouldShowTableView {
      self.setState(.InitialLoadingTableView)
    } else {
      self.setState(.InitialLoading)
    }

    if let delegate = statefulDelegate {
      delegate.statefulTableViewWillBeginInitialLoad(self, handler: { [weak self](tableIsEmpty, errorOrNil) in
        dispatch_async(dispatch_get_main_queue(), {
          self?.setHasFinishedInitialLoad(tableIsEmpty, error: errorOrNil)
        })
      })
    }

    return true
  }

  private func setHasFinishedInitialLoad(tableIsEmpty: Bool, error: NSError?) {
    guard state.isInitialLoading else { return }

    if tableIsEmpty {
      self.setState(.EmptyOrInitialLoadError, updateView: true, error: error)
    } else {
      self.setState(.Idle)
    }
  }
}

extension StatefulTableView {
  // MARK: - Load more

  /**
   Tiggers loading more of data. Also called when the scroll content offset reaches the `loadMoreTriggerThreshold`.
   */
  public func triggerLoadMore() {
    guard !state.isLoading else { return }

    loadMoreViewIsErrorView = false
    lastLoadMoreError = nil
    updateLoadMoreView()

    setState(.LoadingMore)

    if let delegate = statefulDelegate {
      delegate.statefulTableViewWillBeginLoadingMore(self, handler: { [weak self](canLoadMore, errorOrNil, showErrorView) in
        dispatch_async(dispatch_get_main_queue(), {
          self?.setHasFinishedLoadingMore(canLoadMore, error: errorOrNil, showErrorView: showErrorView)
        })
      })
    }
  }

  private func updateLoadMoreView() {
    if watchForLoadMore || lastLoadMoreError != nil {
      tableView.tableFooterView = viewForLoadingMore(withError: (loadMoreViewIsErrorView ? lastLoadMoreError : nil))
    } else {
      tableView.tableFooterView = UIView()
    }
  }

  private func viewForLoadingMore(withError error: NSError?) -> UIView? {
    if let delegateMethod = statefulDelegate?.statefulTableViewLoadMoreErrorView where error != nil {
      return delegateMethod(self, forLoadMoreError: error)
    }

    let container = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: 44)))

    let sub: UIView

    if let error = error {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.text = error.localizedDescription
      label.font = UIFont.systemFontOfSize(12)
      label.textAlignment = .Center
      sub = label
    } else {
      let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      activityIndicator.startAnimating()
      sub = activityIndicator
    }

    container.addSubview(sub)
    centerView(sub, inContainer: container)

    return container
  }

  private func setHasFinishedLoadingMore(canLoadMore: Bool, error: NSError?, showErrorView: Bool) {
    guard state == .LoadingMore else { return }

    self.canLoadMore = canLoadMore
    loadMoreViewIsErrorView = (error != nil) && showErrorView
    lastLoadMoreError = error

    setState(.Idle)
  }

  private func watchForLoadMoreIfApplicable(watch: Bool) {
    var watch = watch

    if (watch && !canLoadMore) {
      watch = false
    }
    watchForLoadMore = watch
    updateLoadMoreView()

    triggerLoadMoreIfApplicable(tableView)
  }

  /**
   Should be called when scrolling the tableView. This determines when to call `triggerLoadMore`

   - parameter scrollView: The scrolling view.
   */
  public func scrollViewDidScroll(scrollView: UIScrollView) {
    triggerLoadMoreIfApplicable(scrollView)
  }

  private func triggerLoadMoreIfApplicable(scrollView: UIScrollView) {
    guard watchForLoadMore && !loadMoreViewIsErrorView else { return }

    let scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y
    if scrollPosition < loadMoreTriggerThreshold {
      triggerLoadMore()
    }
  }
}

// MARK: - States
extension StatefulTableView {
  internal func setState(newState: State) {
    setState(newState, updateView: true, error: nil)
  }

  internal func setState(newState: State, error: NSError?) {
    setState(newState, updateView: true, error: error)
  }

  internal func setState(newState: State, updateView: Bool, error: NSError?) {
    state = newState

    switch state {
    case .InitialLoading:
      resetStaticContentView(withChildView: viewForInitialLoad)
    case .EmptyOrInitialLoadError:
      resetStaticContentView(withChildView: viewForEmptyInitialLoad(withError: error))
    default: break
    }

    switch state {
    case .Idle:
      watchForLoadMoreIfApplicable(true)
    case .EmptyOrInitialLoadError:
      watchForLoadMoreIfApplicable(false)
    default: break
    }

    if updateView {
      let mode: ViewMode

      switch state {
      case .InitialLoading: fallthrough
      case .EmptyOrInitialLoadError:
        mode = .Static
      default: mode = .Table
      }

      viewMode = mode
    }
  }
}

// MARK: - Views
extension StatefulTableView {
  private func resetStaticContentView(withChildView childView: UIView?) {
    staticContentView.subviews.forEach { $0.removeFromSuperview() }

    guard let childView = childView else { return }

    staticContentView.addSubview(childView)

    childView.translatesAutoresizingMaskIntoConstraints = false

    pinView(childView, toContainer: staticContentView)
  }

  private var viewForInitialLoad: UIView? {
    if let delegateMethod = statefulDelegate?.statefulTableViewViewForInitialLoad {
      return delegateMethod(self)
    }

    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    activityIndicatorView.startAnimating()

    return activityIndicatorView
  }

  private func viewForEmptyInitialLoad(withError error: NSError?) -> UIView? {
    if let delegateMethod = statefulDelegate?.statefulTableViewInitialErrorView {
      return delegateMethod(self, forInitialLoadError: error)
    }

    let container = UIView(frame: .zero)

    var centeredSize: CGSize = .zero

    let centered = UIView(frame: .zero)
    centered.translatesAutoresizingMaskIntoConstraints = false

    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .Center
    label.text = error?.localizedDescription ?? "No records found"
    label.sizeToFit()

    label.setWidthConstraintToCurrent()
    label.setHeightConstraintToCurrent()

    centered.addSubview(label)

    apply([.Top, .CenterX], ofView: label, toView: centered)

    centeredSize.width = label.bounds.width
    centeredSize.height = label.bounds.height

    if let _ = error {
      let button = UIButton(type: .System)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setTitle("Try Again", forState: .Normal)
      button.addTarget(self, action: #selector(triggerInitialLoad(_:)), forControlEvents: .TouchUpInside)
      button.sizeToFit()

      button.setWidthConstraintToCurrent()
      button.setHeightConstraintToCurrent()

      centeredSize.width = max(centeredSize.width, button.bounds.width)
      centeredSize.height = label.bounds.height + button.bounds.height + 5

      centered.addSubview(button)

      apply([.Bottom, .CenterX], ofView: button, toView: centered)
    }

    centered.setWidthConstraint(centeredSize.width)
    centered.setHeightConstraint(centeredSize.height)

    container.addSubview(centered)

    centerView(centered, inContainer: container)

    return container
  }
}

// MARK: - Helpers
private extension StatefulTableView {
  private func pinView(view: UIView, toContainer container: UIView) {
    let attributes: [NSLayoutAttribute] = [.Top, .Bottom, .Leading, .Trailing]
    apply(attributes, ofView: view, toView: container)
  }

  private func centerView(view: UIView, inContainer container: UIView) {
    let attributes: [NSLayoutAttribute] = [.CenterX, .CenterY]
    apply(attributes, ofView: view, toView: container)
  }

  private func centerViewHorizontally(view: UIView, inContainer container: UIView) {
    apply([.CenterX], ofView: view, toView: container)
  }

  private func centerViewVertically(view: UIView, inContainer container: UIView) {
    apply([.CenterY], ofView: view, toView: container)
  }

  private func apply(attributes: [NSLayoutAttribute], ofView childView: UIView, toView containerView: UIView) {
    let constraints = attributes.map {
      return NSLayoutConstraint(item: childView, attribute: $0, relatedBy: .Equal,
        toItem: containerView, attribute: $0, multiplier: 1, constant: 0)
    }

    containerView.addConstraints(constraints)
  }
}

private extension UIView {
  private func setWidthConstraintToCurrent() {
    setWidthConstraint(bounds.width)
  }

  private func setHeightConstraintToCurrent() {
    setHeightConstraint(bounds.height)
  }

  private func setWidthConstraint(width: CGFloat) {
    addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil,
      attribute: .NotAnAttribute, multiplier: 1, constant: width))
  }

  private func setHeightConstraint(height: CGFloat) {
    addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil,
      attribute: .NotAnAttribute, multiplier: 1, constant: height))
  }
}