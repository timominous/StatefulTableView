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

  private lazy var tableView = UITableView()

  private lazy var staticContentView: UIView = { [unowned self] in
    let view = UIView(frame: self.bounds)
    view.backgroundColor = .whiteColor()
    view.hidden = true
    return view
  }()

  private lazy var refreshControl = UIRefreshControl()

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

  /**
   The object that acts as the stateful delegate of the table view.

   - Discussion: The stateful delegate must adopt the `StatefulTableDelegate` protocol. The stateful delegate is not retained.
   */
  weak public var statefulDelegate: StatefulTableDelegate?

  func commonInit() {
    addSubview(tableView)
    addSubview(staticContentView)

    refreshControl.addTarget(self,
      action: #selector(refreshControlValueChanged), forControlEvents: .ValueChanged)
    tableView.addSubview(refreshControl)
  }

  /**
   Lays out subviews.

   - Discussion: The default implementation of this method does
   */
  override public func layoutSubviews() {
    super.layoutSubviews()
    tableView.frame = bounds
    staticContentView.frame = bounds
  }
}

// MARK: - UITableView bridge
extension StatefulTableView {
  /// Bridge for UITableivew methods. Read UITableView documentation for more details

  /// Data

  /// Info

  /// Row insertion/deletion/reloading

  /// Editing. When set, rows show insert/delete/reorder control based on data source queries

  /// Selection

  /// Appearance

  public var sectionIndexMinimumDisplayRowCount: Int {
    set { tableView.sectionIndexMinimumDisplayRowCount = newValue }
    get { return tableView.sectionIndexMinimumDisplayRowCount }
  }

  @available(iOS 6.0, *)
  public var sectionIndexColor: UIColor? {
    set { tableView.sectionIndexColor = newValue }
    get { return tableView.sectionIndexColor }
  }

  @available(iOS 7.0, *)
  public var sectionIndexBackgroundColor: UIColor? {
    set { tableView.sectionIndexBackgroundColor = newValue }
    get { return tableView.sectionIndexBackgroundColor }
  }

  @available(iOS 6.0, *)
  public var sectionIndexTrackingBackgroundColor: UIColor? {
    set { tableView.sectionIndexTrackingBackgroundColor = newValue }
    get { return tableView.sectionIndexTrackingBackgroundColor }
  }

  /// Beginning in iOS 6, clients can register a nib or class for each cell.
  /// If all reuse identifiers are registered, use the newer -dequeueReusableCellWithIdentifier:forIndexPath: to guarantee that a cell instance is returned.
  /// Instances returned from the new dequeue method will also be properly sized when they are returned.

  /// Focus

  @available(iOS 9.0, *)
  public var remembersLastFocusedIndexPath: Bool {
    set { tableView.remembersLastFocusedIndexPath = newValue }
    get { return tableView.remembersLastFocusedIndexPath }
  }
}

// MARK: - Configuring a Table View
extension StatefulTableView {
  public func numberOfRowsInSection(section: Int) -> Int {
    return tableView.numberOfRowsInSection(section)
  }

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

  public var separatorStyle: UITableViewCellSeparatorStyle {
    set { tableView.separatorStyle = newValue }
    get { return tableView.separatorStyle }
  }

  public var separatorColor: UIColor? {
    set { tableView.separatorColor = newValue }
    get { return tableView.separatorColor }
  }

  @available(iOS 8.0, *)
  public var separatorEffect: UIVisualEffect? {
    set { tableView.separatorEffect = newValue }
    get { return tableView.separatorEffect }
  }

  @available(iOS 7.0, *)
  public var separatorInset: UIEdgeInsets {
    set { tableView.separatorInset = newValue }
    get { return tableView.separatorInset }
  }

  @available(iOS 9.0, *)
  public var cellLayoutMarginsFollowReadableWidth: Bool {
    set { tableView.cellLayoutMarginsFollowReadableWidth = newValue }
    get { return tableView.cellLayoutMarginsFollowReadableWidth }
  }
}

// MARK: - Creating Table View Cells
extension StatefulTableView {
  @available(iOS 5.0, *)
  public func registerNib(nib: UINib?, forCellReuseIdentifier identifier: String) {
    tableView.registerNib(nib, forCellReuseIdentifier: identifier)
  }

  @available(iOS 6.0, *)
  public func registerClass(cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
    tableView.registerClass(cellClass, forCellReuseIdentifier: identifier)
  }

  @available(iOS 6.0, *)
  public func dequeueReusableCellWithIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
  }

  public func dequeueReusableCellWithIdentifier(identifier: String) -> UITableViewCell? {
    return tableView.dequeueReusableCellWithIdentifier(identifier)
  }
}

// MARK: - Accessing Header and Footer Views
extension StatefulTableView {
  @available(iOS 6.0, *)
  public func registerNib(nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
    tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: identifier)
  }

  @available(iOS 6.0, *)
  public func registerClass(aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
    tableView.registerClass(aClass, forHeaderFooterViewReuseIdentifier: identifier)
  }

  @available(iOS 6.0, *)
  public func dequeueReusableHeaderFooterViewWithIdentifier(identifier: String) -> UITableViewHeaderFooterView? {
    return tableView.dequeueReusableHeaderFooterViewWithIdentifier(identifier)
  }

  public var tableHeaderView: UIView? {
    set { tableView.tableHeaderView = newValue }
    get { return tableView.tableHeaderView }
  }

  public var tableFooterView: UIView? {
    set { tableView.tableFooterView = newValue }
    get { return tableView.tableFooterView }
  }

  public var sectionHeaderHeight: CGFloat {
    set { tableView.sectionHeaderHeight = newValue }
    get { return tableView.sectionHeaderHeight }
  }

  public var sectionFooterHeight: CGFloat {
    set { tableView.sectionFooterHeight = newValue }
    get { return tableView.sectionFooterHeight }
  }

  @available(iOS 6.0, *)
  public func headerViewForSection(section: Int) -> UITableViewHeaderFooterView? {
    return tableView.headerViewForSection(section)
  }

  @available(iOS 6.0, *)
  public func footerViewForSection(section: Int) -> UITableViewHeaderFooterView? {
    return tableView.footerViewForSection(section)
  }
}

// MARK: - Accessing Cells and Sections
extension StatefulTableView {
  public func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
    return tableView.cellForRowAtIndexPath(indexPath)
  }

  public func indexPathForCell(cell: UITableViewCell) -> NSIndexPath? {
    return tableView.indexPathForCell(cell)
  }

  public func indexPathForRowAtPoint(point: CGPoint) -> NSIndexPath? {
    return tableView.indexPathForRowAtPoint(point)
  }

  public func indexPathsForRowsInRect(rect: CGRect) -> [NSIndexPath]? {
    return tableView.indexPathsForRowsInRect(rect)
  }

  public var visibleCells: [UITableViewCell] {
    return tableView.visibleCells
  }

  public var indexPathsForVisibleRows: [NSIndexPath]? {
    return tableView.indexPathsForVisibleRows;
  }
}

// MARK: - Estimating Element Heights
extension StatefulTableView {
  @available(iOS 7.0, *)
  public var estimatedRowHeight: CGFloat {
    set { tableView.estimatedRowHeight = newValue }
    get { return tableView.estimatedRowHeight }
  }

  @available(iOS 7.0, *)
  public var estimatedSectionHeaderHeight: CGFloat {
    set { tableView.estimatedSectionHeaderHeight = newValue }
    get { return tableView.estimatedSectionHeaderHeight }
  }

  @available(iOS 7.0, *)
  public var estimatedSectionFooterHeight: CGFloat {
    set { tableView.estimatedSectionFooterHeight = newValue }
    get { return tableView.estimatedSectionHeaderHeight }
  }
}

// MARK: - Scrolling the Table View
extension StatefulTableView {
  public func scrollToRowAtIndexPath(indexPath: NSIndexPath, atScrollPosition scrollPosition: UITableViewScrollPosition, animated: Bool) {
    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: animated)
  }

  public func scrollToNearestSelectedRowAtScrollPosition(scrollPosition: UITableViewScrollPosition, animated: Bool) {
    tableView.scrollToNearestSelectedRowAtScrollPosition(scrollPosition, animated: animated)
  }
}

// MARK: - Managing Selections
extension StatefulTableView {
  public var indexPathForSelectedRow: NSIndexPath? {
    return tableView.indexPathForSelectedRow
  }

  @available(iOS 5.0, *)
  public var indexPathsForSelectedRows: [NSIndexPath]? {
    return tableView.indexPathsForSelectedRows
  }

  public func selectRowAtIndexPath(indexPath: NSIndexPath?, animated: Bool, scrollPosition: UITableViewScrollPosition) {
    tableView.selectRowAtIndexPath(indexPath, animated: animated, scrollPosition: scrollPosition)
  }

  public func deselectRowAtIndexPath(indexPath: NSIndexPath, animated: Bool) {
    tableView.deselectRowAtIndexPath(indexPath, animated: animated)
  }

  @available(iOS 3.0, *)
  public var allowsSelection: Bool {
    set { tableView.allowsSelection = newValue }
    get { return tableView.allowsSelection }
  }

  @available(iOS 5.0, *)
  public var allowsMultipleSelection: Bool {
    set { tableView.allowsMultipleSelection = newValue }
    get { return tableView.allowsMultipleSelection }
  }

  public var allowsSelectionDuringEditing: Bool {
    set { tableView.allowsSelectionDuringEditing = newValue }
    get { return tableView.allowsSelectionDuringEditing }
  }

  @available(iOS 5.0, *)
  public var allowsMultipleSelectionDuringEditing: Bool {
    set { tableView.allowsMultipleSelectionDuringEditing = newValue }
    get { return tableView.allowsMultipleSelectionDuringEditing }
  }
}

// MARK: - Inserting, Deleting, and Moving Rows and Sections
extension StatefulTableView {
  public func beginUpdates() {
    tableView.beginUpdates()
  }

  public func endUpdates() {
    tableView.endUpdates()
  }

  public func insertRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
    tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
  }

  public func deleteRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
    tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
  }

  @available(iOS 5.0, *)
  public func moveRowAtIndexPath(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
    tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
  }

  public func insertSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
    tableView.insertSections(sections, withRowAnimation: animation)
  }

  public func deleteSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
    tableView.deleteSections(sections, withRowAnimation: animation)
  }

  @available(iOS 5.0, *)
  public func moveSection(section: Int, toSection newSection: Int) {
    tableView.moveSection(section, toSection: newSection)
  }
}

// MARK: - Managing the Editing of Table Cells
extension StatefulTableView {
  public var editing: Bool {
    set { tableView.editing = newValue }
    get { return tableView.editing }
  }

  public func setEditing(editing: Bool, animated: Bool) {
    tableView.setEditing(editing, animated: animated)
  }
}

// MARK: - Reloading the Table View
extension StatefulTableView {
  public func reloadData() {
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
    }
  }

  @available(iOS 3.0, *)
  public func reloadRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
    tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
  }

  @available(iOS 3.0, *)
  public func reloadSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
    tableView.reloadSections(sections, withRowAnimation: animation)
  }

  @available(iOS 3.0, *)
  public func reloadSectionIndexTitles() {
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadSectionIndexTitles()
    }
  }
}

// MARK: - Accessing Drawing Areas of the Table View
extension StatefulTableView {
  public func rectForSection(section: Int) -> CGRect {
    return tableView.rectForSection(section)
  }

  public func rectForRowRowAtIndexPath(indexPath: NSIndexPath) -> CGRect {
    return tableView.rectForRowAtIndexPath(indexPath)
  }

  public func rectForFooterInSection(section: Int) -> CGRect {
    return tableView.rectForFooterInSection(section)
  }

  public func rectFotHeaderInSection(section: Int) -> CGRect {
    return tableView.rectForHeaderInSection(section)
  }
}

// MARK: - Managing the Delegate and the Data Source
extension StatefulTableView {
  /**
   The object that acts as the data source of the table view.

   - Discussion: The data souce must adopt the `UITableViewDataSource` protocol. The data source is not retained.
   */
  public var dataSource: UITableViewDataSource? {
    set { tableView.dataSource = newValue }
    get { return tableView.dataSource }
  }

  /**
   The object that acts as the delegate of the table view.

   - Discussion: The delegate must adopt the `UITableViewDelegate` protocol. The delegate is not retained.
   */
  public var delegate: UITableViewDelegate? {
    set { tableView.delegate = newValue }
    get { return tableView.delegate }
  }
}

// MARK: - Pull to refresh
extension StatefulTableView {
  func refreshControlValueChanged() {
    if state != .LoadingFromPullToRefresh && !state.isLoading {
      if (!triggerPullToRefresh()) {
        refreshControl.endRefreshing()
      }
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

  func setHasFinishedLoadingFromPullToRefresh(tableIsEmpty: Bool, error: NSError?) {
    guard state == .LoadingFromPullToRefresh else { return }

    refreshControl.endRefreshing()

    if tableIsEmpty {
      self.setState(.EmptyOrInitialLoadError, updateView: true, error: error)
    } else {
      self.setState(.Idle)
    }
  }
}

// MARK: - Initial load
extension StatefulTableView {

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

  func setHasFinishedInitialLoad(tableIsEmpty: Bool, error: NSError?) {
    guard state.isInitialLoading else { return }

    if tableIsEmpty {
      self.setState(.EmptyOrInitialLoadError, updateView: true, error: error)
    } else {
      self.setState(.Idle)
    }
  }
}

// MARK: - Load more
extension StatefulTableView {
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

  func updateLoadMoreView() {
    if watchForLoadMore || lastLoadMoreError != nil {
      tableView.tableFooterView = viewForLoadingMore(withError: (loadMoreViewIsErrorView ? lastLoadMoreError : nil))
    } else {
      tableView.tableFooterView = UIView()
    }
  }

  func viewForLoadingMore(withError error: NSError?) -> UIView {
    if let view = statefulDelegate?.statefulTableViewView(self, forLoadMoreError: error) { return view }

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

  func setHasFinishedLoadingMore(canLoadMore: Bool, error: NSError?, showErrorView: Bool) {
    guard state == .LoadingMore else { return }

    self.canLoadMore = canLoadMore
    loadMoreViewIsErrorView = (error != nil) && showErrorView
    lastLoadMoreError = error

    setState(.Idle)
  }

  func watchForLoadMoreIfApplicable(watch: Bool) {
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

  func triggerLoadMoreIfApplicable(scrollView: UIScrollView) {
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
  func resetStaticContentView(withChildView childView: UIView) {
    staticContentView.subviews.forEach { $0.removeFromSuperview() }
    staticContentView.addSubview(childView)

    childView.translatesAutoresizingMaskIntoConstraints = false

    pinView(childView, toContainer: staticContentView)
  }

  var viewForInitialLoad: UIView {
    if let view = statefulDelegate?.statefulTableViewViewForInitialLoad(self) {
      return view
    }

    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    activityIndicatorView.startAnimating()

    return activityIndicatorView
  }

  func viewForEmptyInitialLoad(withError error: NSError?) -> UIView {
    if let view = statefulDelegate?.statefulTableViewView(self, forInitialLoadError: error) { return view }

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
extension StatefulTableView {
  func pinView(view: UIView, toContainer container: UIView) {
    let attributes: [NSLayoutAttribute] = [.Top, .Bottom, .Leading, .Trailing]
    apply(attributes, ofView: view, toView: container)
  }

  func centerView(view: UIView, inContainer container: UIView) {
    let attributes: [NSLayoutAttribute] = [.CenterX, .CenterY]
    apply(attributes, ofView: view, toView: container)
  }

  func centerViewHorizontally(view: UIView, inContainer container: UIView) {
    apply([.CenterX], ofView: view, toView: container)
  }

  func centerViewVertically(view: UIView, inContainer container: UIView) {
    apply([.CenterY], ofView: view, toView: container)
  }

  func apply(attributes: [NSLayoutAttribute], ofView childView: UIView, toView containerView: UIView) {
    let constraints = attributes.map {
      return NSLayoutConstraint(item: childView, attribute: $0, relatedBy: .Equal,
        toItem: containerView, attribute: $0, multiplier: 1, constant: 0)
    }

    containerView.addConstraints(constraints)
  }
}

extension UIView {
  func setWidthConstraintToCurrent() {
    setWidthConstraint(bounds.width)
  }

  func setHeightConstraintToCurrent() {
    setHeightConstraint(bounds.height)
  }

  func setWidthConstraint(width: CGFloat) {
    addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil,
      attribute: .NotAnAttribute, multiplier: 1, constant: width))
  }

  func setHeightConstraint(height: CGFloat) {
    addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil,
      attribute: .NotAnAttribute, multiplier: 1, constant: height))
  }
}