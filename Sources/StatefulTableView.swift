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
  private enum State {
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

  private lazy var tableView = UITableView()

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

  private lazy var refreshControl = UIRefreshControl()

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

  private var state: State = .Idle

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
  // MARK: - Pull to refresh

  func refreshControlValueChanged() {
    if state != .LoadingFromPullToRefresh && !state.isLoading {
      if (!triggerPullToRefresh()) {
        refreshControl.endRefreshing()
      }
    } else {
      refreshControl.endRefreshing()
    }
  }

  /**
   Triggers pull to refresh programatically. Also called when the user pulls down to refresh on the tableView.

   - returns: Boolean for success status.
   */
  public func triggerPullToRefresh() -> Bool {
    guard !state.isLoading && canPullToRefresh else { return false }

    self.setState(.LoadingFromPullToRefresh, updateView: false, error: nil)

    if let delegate = statefulDelegate {
      delegate.statefulTableViewWillBeginLoadingFromRefresh(self, handler: { [weak self](tableIsEmpty, errorOrNil) in
        dispatch_async(dispatch_get_main_queue(), {
          self?.setHasFinishedLoadingFromPullToRefresh(tableIsEmpty, error: errorOrNil)
        })
      })
    }

    refreshControl.beginRefreshing()

    return true
  }

  private func setHasFinishedLoadingFromPullToRefresh(tableIsEmpty: Bool, error: NSError?) {
    guard state == .LoadingFromPullToRefresh else { return }

    refreshControl.endRefreshing()

    if tableIsEmpty {
      self.setState(.EmptyOrInitialLoadError, updateView: true, error: error)
    } else {
      self.setState(.Idle)
    }
  }
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
  private func setState(newState: State) {
    setState(newState, updateView: true, error: nil)
  }

  private func setState(newState: State, error: NSError?) {
    setState(newState, updateView: true, error: error)
  }

  private func setState(newState: State, updateView: Bool, error: NSError?) {
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

extension StatefulTableView {
  // MARK: - Configuring a Table View

  /**
   Returns the number of rows (table cells) in a specified section.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/numberOfRowsInSection:) for more details.
   */
  public func numberOfRowsInSection(section: Int) -> Int {
    return tableView.numberOfRowsInSection(section)
  }

  /**
   The number of sections in the table view. (read-only)

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/numberOfSections) for more details.
   */
  public var numberOfSections: Int {
    return tableView.numberOfSections
  }

  /**
   The height of each row (that is, table cell) in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/rowHeight) for more details
   */
  public var rowHeight: CGFloat {
    set { tableView.rowHeight = newValue }
    get { return tableView.rowHeight }
  }

  /**
   The style for table cells used as separators.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/separatorStyle) for more details.
   */
  public var separatorStyle: UITableViewCellSeparatorStyle {
    set { tableView.separatorStyle = newValue }
    get { return tableView.separatorStyle }
  }

  /**
   The color of separator rows in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/separatorColor) for more details.
   */
  public var separatorColor: UIColor? {
    set { tableView.separatorColor = newValue }
    get { return tableView.separatorColor }
  }

  /**
   The effect applied to table separators.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/separatorEffect) for more details.
   */
  @available(iOS 8.0, *)
  public var separatorEffect: UIVisualEffect? {
    set { tableView.separatorEffect = newValue }
    get { return tableView.separatorEffect }
  }

  /**
   Specifies the default inset of cell separators.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/separatorInset) for more details.
   */
  @available(iOS 7.0, *)
  public var separatorInset: UIEdgeInsets {
    set { tableView.separatorInset = newValue }
    get { return tableView.separatorInset }
  }

  /**
   A Boolean value that indicates whether the cell margins are derived from the width of the readable content guide.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/cellLayoutMarginsFollowReadableWidth) for more details.
   */
  @available(iOS 9.0, *)
  public var cellLayoutMarginsFollowReadableWidth: Bool {
    set { tableView.cellLayoutMarginsFollowReadableWidth = newValue }
    get { return tableView.cellLayoutMarginsFollowReadableWidth }
  }
}

extension StatefulTableView {
  // MARK: - Creating Table View Cells

  /**
   Registers a nib object containing a cell with the table view under a specified identifier.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/registerNib:forCellReuseIdentifier:) for more details.
   */
  @available(iOS 5.0, *)
  public func registerNib(nib: UINib?, forCellReuseIdentifier identifier: String) {
    tableView.registerNib(nib, forCellReuseIdentifier: identifier)
  }

  /**
   Registers a class for use in creating new table cells.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/registerClass:forCellReuseIdentifier:) for more details.
   */
  @available(iOS 6.0, *)
  public func registerClass(cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
    tableView.registerClass(cellClass, forCellReuseIdentifier: identifier)
  }

  /**
   Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/dequeueReusableCellWithIdentifier:forIndexPath:) for more details.
   */
  @available(iOS 6.0, *)
  public func dequeueReusableCellWithIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
  }

  /**
   Returns a reusable table-view cell object located by its identifier.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/dequeueReusableCellWithIdentifier:) for more details.
   */
  public func dequeueReusableCellWithIdentifier(identifier: String) -> UITableViewCell? {
    return tableView.dequeueReusableCellWithIdentifier(identifier)
  }
}

extension StatefulTableView {
  // MARK: - Accessing Header and Footer Views

  /**
   Registers a nib object containing a header or footer with the table view under a specified identifier.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/registerNib:forHeaderFooterViewReuseIdentifier:) for more details.
   */
  @available(iOS 6.0, *)
  public func registerNib(nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
    tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: identifier)
  }

  /**
   Registers a class for use in creating new table header or footer views.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/registerClass:forHeaderFooterViewReuseIdentifier:) for more details.
   */
  @available(iOS 6.0, *)
  public func registerClass(aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
    tableView.registerClass(aClass, forHeaderFooterViewReuseIdentifier: identifier)
  }

  /**
   Returns a reusable header or footer view located by its identifier.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/dequeueReusableHeaderFooterViewWithIdentifier:) for more details.
   */
  @available(iOS 6.0, *)
  public func dequeueReusableHeaderFooterViewWithIdentifier(identifier: String) -> UITableViewHeaderFooterView? {
    return tableView.dequeueReusableHeaderFooterViewWithIdentifier(identifier)
  }

  /**
   Returns an accessory view that is displayed above the table.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/tableHeaderView) for more details.
   */
  public var tableHeaderView: UIView? {
    set { tableView.tableHeaderView = newValue }
    get { return tableView.tableHeaderView }
  }

  /**
   Returns an accessory view that is displayed below the table.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/tableFooterView) for more details.
   */
  public var tableFooterView: UIView? {
    set { tableView.tableFooterView = newValue }
    get { return tableView.tableFooterView }
  }

  /**
   The height of section headers in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/sectionHeaderHeight) for more details.
   */
  public var sectionHeaderHeight: CGFloat {
    set { tableView.sectionHeaderHeight = newValue }
    get { return tableView.sectionHeaderHeight }
  }

  /**
   The height of section footers in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/sectionFooterHeight) for more details.
   */
  public var sectionFooterHeight: CGFloat {
    set { tableView.sectionFooterHeight = newValue }
    get { return tableView.sectionFooterHeight }
  }

  /**
   Returns the header view associated with the specified section.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/headerViewForSection:) for more details.
   */
  @available(iOS 6.0, *)
  public func headerViewForSection(section: Int) -> UITableViewHeaderFooterView? {
    return tableView.headerViewForSection(section)
  }

  /**
   Returns the footer view associated with the specified section.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/footerViewForSection:) for more details.
   */
  @available(iOS 6.0, *)
  public func footerViewForSection(section: Int) -> UITableViewHeaderFooterView? {
    return tableView.footerViewForSection(section)
  }
}

extension StatefulTableView {
  // MARK: - Accessing Cells and Sections

  /**
   Returns the table cell at the specified index path.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/cellForRowAtIndexPath:) for more details.
   */
  public func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
    return tableView.cellForRowAtIndexPath(indexPath)
  }

  /**
   Returns an index path representing the row and section of a given table-view cell.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/indexPathForCell:) for more details.
   */
  public func indexPathForCell(cell: UITableViewCell) -> NSIndexPath? {
    return tableView.indexPathForCell(cell)
  }

  /**
   Returns an index path identifying the row and section at the given point.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/indexPathForRowAtPoint:) for more details.
   */
  public func indexPathForRowAtPoint(point: CGPoint) -> NSIndexPath? {
    return tableView.indexPathForRowAtPoint(point)
  }

  /**
   An array of index paths each representing a row enclosed by a given rectangle.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/indexPathsForRowsInRect:) for more details.
   */
  public func indexPathsForRowsInRect(rect: CGRect) -> [NSIndexPath]? {
    return tableView.indexPathsForRowsInRect(rect)
  }

  /**
   The table cells that are visible in the table view. (read-only)

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/visibleCells) for more details.
   */
  public var visibleCells: [UITableViewCell] {
    return tableView.visibleCells
  }

  /**
   An array of index paths each identifying a visible row in the table view. (read-only)

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/indexPathsForVisibleRows) for more details.
   */
  public var indexPathsForVisibleRows: [NSIndexPath]? {
    return tableView.indexPathsForVisibleRows;
  }
}

extension StatefulTableView {
  // MARK: - Estimating Element Heights

  /**
   The estimated height of rows in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/estimatedRowHeight) for more details.
   */
  @available(iOS 7.0, *)
  public var estimatedRowHeight: CGFloat {
    set { tableView.estimatedRowHeight = newValue }
    get { return tableView.estimatedRowHeight }
  }

  /**
   The estimated height of section headers in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/estimatedSectionHeaderHeight) for more details.
   */
  @available(iOS 7.0, *)
  public var estimatedSectionHeaderHeight: CGFloat {
    set { tableView.estimatedSectionHeaderHeight = newValue }
    get { return tableView.estimatedSectionHeaderHeight }
  }

  /**
   The estimated height of section footers in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/estimatedSectionFooterHeight) for more details.
   */
  @available(iOS 7.0, *)
  public var estimatedSectionFooterHeight: CGFloat {
    set { tableView.estimatedSectionFooterHeight = newValue }
    get { return tableView.estimatedSectionHeaderHeight }
  }
}

extension StatefulTableView {
  // MARK: - Scrolling the Table View

  /**
   Scrolls through the table view until a row identified by index path is at a particular location on the screen.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/scrollToRowAtIndexPath:atScrollPosition:animated:) for more details.
   */
  public func scrollToRowAtIndexPath(indexPath: NSIndexPath, atScrollPosition scrollPosition: UITableViewScrollPosition, animated: Bool) {
    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: animated)
  }

  /**
   Scrolls the table view so that the selected row nearest to a specified position in the table view is at that position.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/scrollToNearestSelectedRowAtScrollPosition:animated:) for more details.
   */
  public func scrollToNearestSelectedRowAtScrollPosition(scrollPosition: UITableViewScrollPosition, animated: Bool) {
    tableView.scrollToNearestSelectedRowAtScrollPosition(scrollPosition, animated: animated)
  }
}

extension StatefulTableView {
  // MARK: - Managing Selections

  /**
   An index path identifying the row and section of the selected row. (read-only)

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/indexPathForSelectedRow) for more details.
   */
  public var indexPathForSelectedRow: NSIndexPath? {
    return tableView.indexPathForSelectedRow
  }

  /**
   The index paths representing the selected rows. (read-only)

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/indexPathsForSelectedRows) for more details.
   */
  @available(iOS 5.0, *)
  public var indexPathsForSelectedRows: [NSIndexPath]? {
    return tableView.indexPathsForSelectedRows
  }

  /**
   Selects a row in the table view identified by index path, optionally scrolling the row to a location in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/selectRowAtIndexPath:animated:scrollPosition:) for more details.
   */
  public func selectRowAtIndexPath(indexPath: NSIndexPath?, animated: Bool, scrollPosition: UITableViewScrollPosition) {
    tableView.selectRowAtIndexPath(indexPath, animated: animated, scrollPosition: scrollPosition)
  }

  /**
   Deselects a given row identified by index path, with an option to animate the deselection.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/deselectRowAtIndexPath:animated:) for more details.
   */
  public func deselectRowAtIndexPath(indexPath: NSIndexPath, animated: Bool) {
    tableView.deselectRowAtIndexPath(indexPath, animated: animated)
  }

  /**
   A Boolean value that determines whether users can select a row.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/allowsSelection) for more details.
   */
  @available(iOS 3.0, *)
  public var allowsSelection: Bool {
    set { tableView.allowsSelection = newValue }
    get { return tableView.allowsSelection }
  }

  /**
   A Boolean value that determines whether users can select more than one row outside of editing mode.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/allowsMultipleSelectionhttps://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/allowsMultipleSelection) for more details.
   */
  @available(iOS 5.0, *)
  public var allowsMultipleSelection: Bool {
    set { tableView.allowsMultipleSelection = newValue }
    get { return tableView.allowsMultipleSelection }
  }

  /**
   A Boolean value that determines whether users can select cells while the table view is in editing mode.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/allowsSelectionDuringEditing) for more details.
   */
  public var allowsSelectionDuringEditing: Bool {
    set { tableView.allowsSelectionDuringEditing = newValue }
    get { return tableView.allowsSelectionDuringEditing }
  }

  /**
   A Boolean value that controls whether users can select more than one cell simultaneously in editing mode.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/allowsMultipleSelectionDuringEditing) for more details.
   */
  @available(iOS 5.0, *)
  public var allowsMultipleSelectionDuringEditing: Bool {
    set { tableView.allowsMultipleSelectionDuringEditing = newValue }
    get { return tableView.allowsMultipleSelectionDuringEditing }
  }
}

extension StatefulTableView {
  // MARK: - Inserting, Deleting, and Moving Rows and Sections

  /**
   Begins a series of method calls that insert, delete, or select rows and sections of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/beginUpdates) for more details.
   */
  public func beginUpdates() {
    tableView.beginUpdates()
  }

  /**
   Concludes a series of method calls that insert, delete, select, or reload rows and sections of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/endUpdates) for more details.
   */
  public func endUpdates() {
    tableView.endUpdates()
  }

  /**
   Inserts rows in the table view at the locations identified by an array of index paths, with an option to animate the insertion.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/insertRowsAtIndexPaths:withRowAnimation:) for more details.
   */
  public func insertRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
    tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
  }

  /**
   Deletes the rows specified by an array of index paths, with an option to animate the deletion.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/deleteRowsAtIndexPaths:withRowAnimation:) for more details.
   */
  public func deleteRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
    tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
  }

  /**
   Moves the row at a specified location to a destination location.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/moveRowAtIndexPath:toIndexPath:) for more details.
   */
  @available(iOS 5.0, *)
  public func moveRowAtIndexPath(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
    tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
  }

  /**
   Inserts one or more sections in the table view, with an option to animate the insertion.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/insertSections:withRowAnimation:) for more details.
   */
  public func insertSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
    tableView.insertSections(sections, withRowAnimation: animation)
  }

  /**
   Deletes one or more sections in the table view, with an option to animate the deletion.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/deleteSections:withRowAnimation:) for more details.
   */
  public func deleteSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
    tableView.deleteSections(sections, withRowAnimation: animation)
  }

  /**
   Moves a section to a new location in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/moveSection:toSection:) for more details.
   */
  @available(iOS 5.0, *)
  public func moveSection(section: Int, toSection newSection: Int) {
    tableView.moveSection(section, toSection: newSection)
  }
}

extension StatefulTableView {
  // MARK: - Managing the Editing of Table Cells

  /**
   A Boolean value that determines whether the table view is in editing mode.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/editing) for more details.
   */
  public var editing: Bool {
    set { tableView.editing = newValue }
    get { return tableView.editing }
  }

  /**
   Toggles the table view into and out of editing mode.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/setEditing:animated:) for more details.
   */
  public func setEditing(editing: Bool, animated: Bool) {
    tableView.setEditing(editing, animated: animated)
  }
}

extension StatefulTableView {
  // MARK: - Reloading the Table View

  /**
   Reloads the rows and sections of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/reloadData) for more details.
   */
  public func reloadData() {
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
    }
  }

  /**
   Reloads the specified rows using an animation effect.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/reloadRowsAtIndexPaths:withRowAnimation:) for more details.
   */
  @available(iOS 3.0, *)
  public func reloadRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
    tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
  }

  /**
   Reloads the specified sections using a given animation effect.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/reloadSections:withRowAnimation:) for more details.
   */
  @available(iOS 3.0, *)
  public func reloadSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
    tableView.reloadSections(sections, withRowAnimation: animation)
  }

  /**
   Reloads the items in the index bar along the right side of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/reloadSectionIndexTitles) for more details.
   */
  @available(iOS 3.0, *)
  public func reloadSectionIndexTitles() {
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadSectionIndexTitles()
    }
  }
}

extension StatefulTableView {
  // MARK: - Accessing Drawing Areas of the Table View

  /**
   Returns the drawing area for a specified section of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/rectForSection:) for more details.
   */
  public func rectForSection(section: Int) -> CGRect {
    return tableView.rectForSection(section)
  }

  /**
   Returns the drawing area for a row identified by index path.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/rectForRowAtIndexPath:) for more details.
   */
  public func rectForRowRowAtIndexPath(indexPath: NSIndexPath) -> CGRect {
    return tableView.rectForRowAtIndexPath(indexPath)
  }

  /**
   Returns the drawing area for the footer of the specified section.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/rectForFooterInSection:) for more details.
   */
  public func rectForFooterInSection(section: Int) -> CGRect {
    return tableView.rectForFooterInSection(section)
  }

  /**
   Returns the drawing area for the header of the specified section.

   - Discussion: Visit this [link](Returns the drawing area for the header of the specified section.) for more details.
   */
  public func rectFotHeaderInSection(section: Int) -> CGRect {
    return tableView.rectForHeaderInSection(section)
  }
}

extension StatefulTableView {
  // MARK: - Managing the Delegate and the Data Source

  /**
   The object that acts as the data source of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/dataSource) for more details.
   */
  public var dataSource: UITableViewDataSource? {
    set { tableView.dataSource = newValue }
    get { return tableView.dataSource }
  }

  /**
   The object that acts as the delegate of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/delegate) for more details
   */
  public var delegate: UITableViewDelegate? {
    set { tableView.delegate = newValue }
    get { return tableView.delegate }
  }
}

extension StatefulTableView {
  // MARK: - Configuring the Table Index

  /**
   The number of table rows at which to display the index list on the right edge of the table.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/sectionIndexMinimumDisplayRowCount) for more details.
   */
  public var sectionIndexMinimumDisplayRowCount: Int {
    set { tableView.sectionIndexMinimumDisplayRowCount = newValue }
    get { return tableView.sectionIndexMinimumDisplayRowCount }
  }

  /**
   The color to use for the table view’s index text.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/sectionIndexColor) for more details.
   */
  @available(iOS 6.0, *)
  public var sectionIndexColor: UIColor? {
    set { tableView.sectionIndexColor = newValue }
    get { return tableView.sectionIndexColor }
  }

  /**
   The color to use for the background of the table view’s section index while not being touched.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/sectionIndexBackgroundColor) for more details.
   */
  @available(iOS 7.0, *)
  public var sectionIndexBackgroundColor: UIColor? {
    set { tableView.sectionIndexBackgroundColor = newValue }
    get { return tableView.sectionIndexBackgroundColor }
  }

  /**
   The color to use for the table view’s index background area.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/sectionIndexTrackingBackgroundColor) for more details.
   */
  @available(iOS 6.0, *)
  public var sectionIndexTrackingBackgroundColor: UIColor? {
    set { tableView.sectionIndexTrackingBackgroundColor = newValue }
    get { return tableView.sectionIndexTrackingBackgroundColor }
  }
}

extension StatefulTableView {
  // MARK: - Managing Focus

  /**
   A Boolean value that indicates whether the table view should automatically return the focus to the cell at the last focused index path.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/remembersLastFocusedIndexPath) for more details.
   */
  @available(iOS 9.0, *)
  public var remembersLastFocusedIndexPath: Bool {
    set { tableView.remembersLastFocusedIndexPath = newValue }
    get { return tableView.remembersLastFocusedIndexPath }
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