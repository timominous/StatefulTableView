//
//  StatefulTableView.swift
//  Demo
//
//  Created by Tim on 12/05/2016.
//  Copyright © 2016 timominous. All rights reserved.
//

import UIKit

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

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  private lazy var tableView = UITableView()
  public var internalTable: UITableView {
    return tableView
  }

  private lazy var staticContentView: UIView = { [unowned self] in
    let view = UIView(frame: self.bounds)
    view.backgroundColor = .whiteColor()
    view.hidden = true
    return view
  }()

  private lazy var refreshControl = UIRefreshControl()

  /// Enables the user to pull down on the tableView to initiate a refresh
  public var canPullToRefresh = false

  /// Enables the user to control whether to trigger loading of more objects or not
  public var canLoadMore = false

  /// Distance from the bottom  of the tableView's vertical content offset where load more will be triggered
  public var loadMoreTriggerThreshold: CGFloat = 64

  /// Determines if the load more view is for an error or not
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

  public var statefulDelegate: StatefulTableDelegate?
  public var dataSource: UITableViewDataSource? {
    set { tableView.dataSource = newValue }
    get { return tableView.dataSource }
  }

  public var delegate: UITableViewDelegate? {
    set { tableView.delegate = newValue }
    get { return tableView.delegate }
  }

  func commonInit() {
    addSubview(tableView)
    addSubview(staticContentView)

    refreshControl.addTarget(self,
      action: #selector(refreshControlValueChanged), forControlEvents: .ValueChanged)
    tableView.addSubview(refreshControl)
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    tableView.frame = bounds
    staticContentView.frame = bounds
  }
}

// MARK: - UITableView bridge
extension StatefulTableView {
  /// Bridge for UITableivew methods. Read UITableView documentation for more details

  public var rowHeight: CGFloat {
    set { tableView.rowHeight = newValue }
    get { return tableView.rowHeight }
  }

  public var sectionHeaderHeight: CGFloat {
    set { tableView.sectionHeaderHeight = newValue }
    get { return tableView.sectionHeaderHeight }
  }

  public var sectionFooterHeight: CGFloat {
    set { tableView.sectionFooterHeight = newValue }
    get { return tableView.sectionFooterHeight }
  }

  public var estimatedRowHeight: CGFloat {
    set { tableView.estimatedRowHeight = newValue }
    get { return tableView.estimatedRowHeight }
  }

  public var estimatedSectionHeaderHeight: CGFloat {
    set { tableView.estimatedSectionHeaderHeight = newValue }
    get { return tableView.estimatedSectionHeaderHeight }
  }

  public var estimatedSectionFooterHeight: CGFloat {
    set { tableView.estimatedSectionFooterHeight = newValue }
    get { return tableView.estimatedSectionHeaderHeight }
  }

  public var separatorInset: UIEdgeInsets {
    set { tableView.separatorInset = newValue }
    get { return tableView.separatorInset }
  }

  /// Data

  public func reloadData() {
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
    }
  }

  public func reloadSectionIndexTitles() {
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadSectionIndexTitles()
    }
  }

  /// Info

  public var numberOfSections: Int {
    return tableView.numberOfSections
  }

  public func numberOfRowsInSection(section: Int) -> Int {
    return tableView.numberOfRowsInSection(section)
  }

  public func rectForSection(section: Int) -> CGRect {
    return tableView.rectForSection(section)
  }

  public func rectFotHeaderInSection(section: Int) -> CGRect {
    return tableView.rectForHeaderInSection(section)
  }

  public func rectForFooterInSection(section: Int) -> CGRect {
    return tableView.rectForFooterInSection(section)
  }

  public func rectForRowRowAtIndexPath(indexPath: NSIndexPath) -> CGRect {
    return tableView.rectForRowAtIndexPath(indexPath)
  }

  public func indexPathForRowAtPoint(point: CGPoint) -> NSIndexPath? {
    return tableView.indexPathForRowAtPoint(point)
  }

  public func indexPathForCell(cell: UITableViewCell) -> NSIndexPath? {
    return tableView.indexPathForCell(cell)
  }

  public func indexPathsForRowsInRect(rect: CGRect) -> [NSIndexPath]? {
    return tableView.indexPathsForRowsInRect(rect)
  }

  public func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
    return tableView.cellForRowAtIndexPath(indexPath)
  }

  public var visibleCells: [UITableViewCell] {
    return tableView.visibleCells
  }

  public var indexPathsForVisibleRows: [NSIndexPath]? {
    return tableView.indexPathsForVisibleRows;
  }

  public func headerViewForSection(section: Int) -> UITableViewHeaderFooterView? {
    return tableView.headerViewForSection(section)
  }

  public func footerViewForSection(section: Int) -> UITableViewHeaderFooterView? {
    return tableView.footerViewForSection(section)
  }

  public func scrollToRowAtIndexPath(indexPath: NSIndexPath, atScrollPosition scrollPosition: UITableViewScrollPosition, animated: Bool) {
    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: animated)
  }

  public func scrollToNearestSelectedRowAtScrollPosition(scrollPosition: UITableViewScrollPosition, animated: Bool) {
    tableView.scrollToNearestSelectedRowAtScrollPosition(scrollPosition, animated: animated)
  }

  /// Row insertion/deletion/reloading

  public func beginUpdates() {
    tableView.beginUpdates()
  }

  public func endUpdates() {
    tableView.endUpdates()
  }

  public func insertSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
    tableView.insertSections(sections, withRowAnimation: animation)
  }

  public func deleteSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
    tableView.deleteSections(sections, withRowAnimation: animation)
  }

  public func reloadSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
    tableView.reloadSections(sections, withRowAnimation: animation)
  }

  public func moveSection(section: Int, toSection newSection: Int) {
    tableView.moveSection(section, toSection: newSection)
  }

  public func insertRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
    tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
  }

  public func deleteRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
    tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
  }

  public func reloadRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
    tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
  }

  public func moveRowAtIndexPath(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
    tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
  }

  /// Editing. When set, rows show insert/delete/reorder control based on data source queries

  public var editing: Bool {
    set { tableView.editing = newValue }
    get { return tableView.editing }
  }

  public func setEditing(editing: Bool, animated: Bool) {
    tableView.setEditing(editing, animated: animated)
  }

  public var allowsSelection: Bool {
    set { tableView.allowsSelection = newValue }
    get { return tableView.allowsSelection }
  }

  public var allowsSelectionDuringEditing: Bool {
    set { tableView.allowsSelectionDuringEditing = newValue }
    get { return tableView.allowsSelectionDuringEditing }
  }

  public var allowsMultipleSelection: Bool {
    set { tableView.allowsMultipleSelection = newValue }
    get { return tableView.allowsMultipleSelection }
  }

  public var allowsMultipleSelectionDuringEditing: Bool {
    set { tableView.allowsMultipleSelectionDuringEditing = newValue }
    get { return tableView.allowsMultipleSelectionDuringEditing }
  }

  /// Selection

  public var indexPathForSelectedRow: NSIndexPath? {
    return tableView.indexPathForSelectedRow
  }

  public var indexPathsForSelectedRows: [NSIndexPath]? {
    return tableView.indexPathsForSelectedRows
  }

  public func selectRowAtIndexPath(indexPath: NSIndexPath?, animated: Bool, scrollPosition: UITableViewScrollPosition) {
    tableView.selectRowAtIndexPath(indexPath, animated: animated, scrollPosition: scrollPosition)
  }

  public func deselectRowAtIndexPath(indexPath: NSIndexPath, animated: Bool) {
    tableView.deselectRowAtIndexPath(indexPath, animated: animated)
  }

  /// Appearance

  public var sectionIndexMinimumDisplayRowCount: Int {
    set { tableView.sectionIndexMinimumDisplayRowCount = newValue }
    get { return tableView.sectionIndexMinimumDisplayRowCount }
  }

  public var sectionIndexColor: UIColor? {
    set { tableView.sectionIndexColor = newValue }
    get { return tableView.sectionIndexColor }
  }

  public var sectionIndexBackgroundColor: UIColor? {
    set { tableView.sectionIndexBackgroundColor = newValue }
    get { return tableView.sectionIndexBackgroundColor }
  }

  public var sectionIndexTrackingBackgroundColor: UIColor? {
    set { tableView.sectionIndexTrackingBackgroundColor = newValue }
    get { return tableView.sectionIndexTrackingBackgroundColor }
  }

  public var separatorStyle: UITableViewCellSeparatorStyle {
    set { tableView.separatorStyle = newValue }
    get { return tableView.separatorStyle }
  }

  public var separatorColor: UIColor? {
    set { tableView.separatorColor = newValue }
    get { return tableView.separatorColor }
  }

  public var separatorEffect: UIVisualEffect? {
    set { tableView.separatorEffect = newValue }
    get { return tableView.separatorEffect }
  }

  @available(iOS 9.0, *)
  public var cellLayoutMarginsFollowReadableWidth: Bool {
    set { tableView.cellLayoutMarginsFollowReadableWidth = newValue }
    get { return tableView.cellLayoutMarginsFollowReadableWidth }
  }

  public var tableHeaderView: UIView? {
    set { tableView.tableHeaderView = newValue }
    get { return tableView.tableHeaderView }
  }

  public var tableFooterView: UIView? {
    set { tableView.tableFooterView = newValue }
    get { return tableView.tableFooterView }
  }

  public func dequeueReusableCellWithIdentifier(identifier: String) -> UITableViewCell? {
    return tableView.dequeueReusableCellWithIdentifier(identifier)
  }

  public func dequeueReusableCellWithIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
  }

  public func dequeueReusableHeaderFooterViewWithIdentifier(identifier: String) -> UITableViewHeaderFooterView? {
    return tableView.dequeueReusableHeaderFooterViewWithIdentifier(identifier)
  }

  /// Beginning in iOS 6, clients can register a nib or class for each cell.
  /// If all reuse identifiers are registered, use the newer -dequeueReusableCellWithIdentifier:forIndexPath: to guarantee that a cell instance is returned.
  /// Instances returned from the new dequeue method will also be properly sized when they are returned.

  @available(iOS 5.0, *)
  public func registerNib(nib: UINib?, forCellReuseIdentifier identifier: String) {
    tableView.registerNib(nib, forCellReuseIdentifier: identifier)
  }

  @available(iOS 6.0, *)
  public func registerClass(cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
    tableView.registerClass(cellClass, forCellReuseIdentifier: identifier)
  }

  @available(iOS 6.0, *)
  public func registerNib(nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
    tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: identifier)
  }

  @available(iOS 6.0, *)
  public func registerClass(aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
    tableView.registerClass(aClass, forHeaderFooterViewReuseIdentifier: identifier)
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

  public func triggerPullToRefresh() -> Bool {
    guard !state.isLoading && canPullToRefresh else { return false }

    self.setState(.LoadingFromPullToRefresh, updateView: false, error: nil)

    if let delegate = statefulDelegate {
      delegate.statefulTableViewWillBeginLoadingFromRefresh(self, handler: { [weak self](tableIsEmpty, errorOrNil) in
        self?.setHasFinishedLoadingFromPullToRefresh(tableIsEmpty, error: errorOrNil)
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
  public func triggerInitialLoad() -> Bool {
    return triggerInitialLoad(false)
  }

  public func triggerInitialLoad(shouldShowTableView: Bool) -> Bool {
    guard !state.isLoading else { return false }

    if shouldShowTableView {
      self.setState(.InitialLoadingTableView)
    } else {
      self.setState(.InitialLoading)
    }

    if let delegate = statefulDelegate {
      delegate.statefulTableViewWillBeginInitialLoad(self, handler: { [weak self](tableIsEmpty, errorOrNil) in
        self?.setHasFinishedInitialLoad(tableIsEmpty, error: errorOrNil)
      })
    }

    return true
  }

  func setHasFinishedInitialLoad(tableIsEmpty: Bool, error: NSError?) {
    guard state == .InitialLoading || state == .InitialLoadingTableView else { return }

    if tableIsEmpty {
      self.setState(.EmptyOrInitialLoadError, updateView: true, error: error)
    } else {
      self.setState(.Idle)
    }
  }
}

// MARK: - Load more
extension StatefulTableView {
  public func triggerLoadMore() {
    guard !state.isLoading else { return }

    loadMoreViewIsErrorView = false
    lastLoadMoreError = nil
    updateLoadMoreView()

    setState(.LoadingMore)

    if let delegate = statefulDelegate {
      delegate.statefulTableViewWillBeginLoadingMore(self, handler: { [weak self](canLoadMore, errorOrNil, showErrorView) in
        self?.setHasFinishedLoadingMore(canLoadMore, error: errorOrNil, showErrorView: showErrorView)
      })
    }
  }

  func updateLoadMoreView() {
    if watchForLoadMore {
      tableView.tableFooterView = viewForLoadingMore(withError: (loadMoreViewIsErrorView ? lastLoadMoreError : nil))
    } else {
      tableView.tableFooterView = UIView()
    }
  }

  func viewForLoadingMore(withError error: NSError?) -> UIView {
    if let view = statefulDelegate?.statefulTableViewView(self, forLoadMoreError: error) { return view }

    let container = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: 44)))

    if let error = error {
      let label = UILabel()
      label.text = error.localizedDescription
      label.font = UIFont.systemFontOfSize(12)
      label.textAlignment = .Center
      label.frame = container.bounds
      container.addSubview(label)
    } else {
      let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
      activityIndicator.frame.centerInFrame(container.bounds)
      activityIndicator.startAnimating()
      container.addSubview(activityIndicator)
    }

    return container
  }

  func setHasFinishedLoadingMore(canLoadMore: Bool, error: NSError?, showErrorView: Bool) {
    guard state == .LoadingMore else { return }

    self.canLoadMore = canLoadMore
    loadMoreViewIsErrorView = (error != nil) && showErrorView
    lastLoadMoreError = error

    if let _ = error {
      updateLoadMoreView()
    }

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

    let attributes: [NSLayoutAttribute] = [.Top, .Bottom, .Leading, .Trailing]
    let constraints = attributes.map {
      return NSLayoutConstraint(item: childView, attribute: $0, relatedBy: .Equal,
        toItem: staticContentView, attribute: $0, multiplier: 1, constant: 0)
    }

    staticContentView.addConstraints(constraints)
  }

  var viewForInitialLoad: UIView {
    if let view = statefulDelegate?.statefulTableViewViewForInitialLoad(self) {
      return view
    }

    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    activityIndicatorView.startAnimating()
    activityIndicatorView.frame.centerInFrame(staticContentView.bounds)

    return activityIndicatorView
  }

  func viewForEmptyInitialLoad(withError error: NSError?) -> UIView {
    if let view = statefulDelegate?.statefulTableViewView(self, forInitialLoadError: error) { return view }

    var frame = CGRect(origin: .zero, size: CGSize(width: staticContentView.bounds.width, height: 120))
    frame.centerInFrame(staticContentView.bounds)

    let container = UIView(frame: frame)

    let label = UILabel()
    label.textAlignment = .Center
    label.text = error?.localizedDescription ?? "No records found"
    label.sizeToFit()

    label.frame.origin.x = (container.bounds.width - label.bounds.width) * 0.5

    if let _ = error {
      let button = UIButton(type: .System)
      button.setTitle("Try Again", forState: .Normal)
      button.addTarget(self, action: #selector(triggerPullToRefresh), forControlEvents: .TouchUpInside)

      button.frame.size = CGSize(width: 130, height: 32)
      button.frame.origin.x = (container.bounds.width - button.bounds.width) * 0.5
      button.frame.origin.y = label.frame.maxY + 10

      container.addSubview(button)
    }

    container.addSubview(label)

    return container
  }
}