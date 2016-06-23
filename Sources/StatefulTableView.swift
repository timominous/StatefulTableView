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

extension StatefulTableView {
  // MARK: - Views

  internal func resetStaticContentView(withChildView childView: UIView?) {
    staticContentView.subviews.forEach { $0.removeFromSuperview() }

    guard let childView = childView else { return }

    staticContentView.addSubview(childView)

    childView.translatesAutoresizingMaskIntoConstraints = false

    pinView(childView, toContainer: staticContentView)
  }

  internal var viewForInitialLoad: UIView? {
    if let delegateMethod = statefulDelegate?.statefulTableViewViewForInitialLoad {
      return delegateMethod(self)
    }

    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    activityIndicatorView.startAnimating()

    return activityIndicatorView
  }

  internal func viewForEmptyInitialLoad(withError error: NSError?) -> UIView? {
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

internal extension StatefulTableView {
  // MARK: - Helpers

  internal func pinView(view: UIView, toContainer container: UIView) {
    let attributes: [NSLayoutAttribute] = [.Top, .Bottom, .Leading, .Trailing]
    apply(attributes, ofView: view, toView: container)
  }

  internal func centerView(view: UIView, inContainer container: UIView) {
    let attributes: [NSLayoutAttribute] = [.CenterX, .CenterY]
    apply(attributes, ofView: view, toView: container)
  }

  internal func centerViewHorizontally(view: UIView, inContainer container: UIView) {
    apply([.CenterX], ofView: view, toView: container)
  }

  internal func centerViewVertically(view: UIView, inContainer container: UIView) {
    apply([.CenterY], ofView: view, toView: container)
  }

  internal func apply(attributes: [NSLayoutAttribute], ofView childView: UIView, toView containerView: UIView) {
    let constraints = attributes.map {
      return NSLayoutConstraint(item: childView, attribute: $0, relatedBy: .Equal,
        toItem: containerView, attribute: $0, multiplier: 1, constant: 0)
    }

    containerView.addConstraints(constraints)
  }
}

internal extension UIView {
  internal func setWidthConstraintToCurrent() {
    setWidthConstraint(bounds.width)
  }

  internal func setHeightConstraintToCurrent() {
    setHeightConstraint(bounds.height)
  }

  internal func setWidthConstraint(width: CGFloat) {
    addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil,
      attribute: .NotAnAttribute, multiplier: 1, constant: width))
  }

  internal func setHeightConstraint(height: CGFloat) {
    addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil,
      attribute: .NotAnAttribute, multiplier: 1, constant: height))
  }
}