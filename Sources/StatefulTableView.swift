//
//  StatefulTableView.swift
//  Demo
//
//  Created by Tim on 12/05/2016.
//  Copyright © 2016 timominous. All rights reserved.
//

import UIKit

final class StatefulTableView: UIView {
  enum State {
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
      default:
        return false
      }
    }

    var isInitialLoading: Bool {
      switch self {
      case .InitialLoading: fallthrough
      case .InitialLoadingTableView:
        return true
      default:
        return false
      }
    }
  }

  enum ViewMode {
    case Table
    case Static
  }

  private lazy var tableView = UITableView()

  private lazy var staticContentView: UIView = { [unowned self] in
    let view = UIView(frame: self.bounds)
    view.backgroundColor = .whiteColor()
    view.hidden = true
    return view
  }()

  private lazy var refreshControl = UIRefreshControl()

  var canPullToRefresh = false
  var canLoadMore = false
  var loadMoreTriggerThreshold = 64

  private var state: State = .Idle

  private var viewMode: ViewMode = .Table {
    didSet {
      let hidden = viewMode == .Table

      guard staticContentView.hidden != hidden else {
        return
      }

      staticContentView.hidden = hidden
    }
  }

  @IBOutlet var statefulDelegate: StatefulTableDelegate?

  @IBOutlet var tableDataSource: UITableViewDataSource? {
    didSet {
      tableView.dataSource = tableDataSource
    }
  }

  @IBOutlet var tableDelegate: UITableViewDelegate? {
    didSet {
      tableView.delegate = tableDelegate
    }
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  override init(frame: CGRect) {
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

  override func layoutSubviews() {
    super.layoutSubviews()
    tableView.frame = bounds
    staticContentView.frame = bounds
  }

  func registerClass(cellClass: AnyClass?, forCellReuseIdentifier: String) {
    tableView.registerClass(cellClass, forCellReuseIdentifier: forCellReuseIdentifier)
  }
}

// MARK: Pull to refresh
extension StatefulTableView {
  func refreshControlValueChanged() {
    if state != .LoadingFromPullToRefresh && !state.isLoading {
      if (!triggerPullToRefresh()) {
        refreshControl.endRefreshing()
      }
    }
  }

  func triggerPullToRefresh() -> Bool {
    guard !state.isLoading && canPullToRefresh else {
      return false
    }

    self.setState(.LoadingFromPullToRefresh, updateView: false, error: nil)

    if let statefulDelegate = statefulDelegate {
      statefulDelegate.statefulTableViewWillBeginLoadingFromRefresh(self, handler: { [weak self](tableIsEmpty, errorOrNil) in
        guard let wself = self else { return }
        wself.setHasFinishedLoadingFromPullToRefresh(tableIsEmpty, error: errorOrNil)
      })
    }

    refreshControl.beginRefreshing()

    return true
  }

  func setHasFinishedLoadingFromPullToRefresh(tableIsEmpty: Bool, error: NSError?) {
    guard state == .LoadingFromPullToRefresh else {
      return
    }

    refreshControl.endRefreshing()

    if tableIsEmpty {
      self.setState(.EmptyOrInitialLoadError, updateView: true, error: error)
    } else {
      self.setState(.Idle)
    }
  }
}

// MARK: States
extension StatefulTableView {
  func setState(newState: State) {
    setState(newState, updateView: true, error: nil)
  }

  func setState(newState: State, error: NSError?) {
    setState(newState, updateView: true, error: error)
  }

  func setState(newState: State, updateView: Bool, error: NSError?) {
    state = newState

    switch state {
    case .InitialLoading:
      resetStaticContentView(withChildView: viewForInitialLoad)
    case .EmptyOrInitialLoadError:
      resetStaticContentView(withChildView: viewForEmptyInitialLoad(withError: error))
    default: break
    }

    if updateView {
      let mode: ViewMode

      switch state {
      case .InitialLoading: fallthrough
      case .EmptyOrInitialLoadError:
        mode = .Static
      default:
        mode = .Table
      }

      viewMode = mode
    }
  }
}

// MARK: Views
extension StatefulTableView {
  func resetStaticContentView(withChildView childView: UIView) {
    staticContentView.subviews.forEach { $0.removeFromSuperview() }
    staticContentView.addSubview(childView)
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
    if let view = statefulDelegate?.statefulTableViewView(self, forInitialLoadError: error) {
      return view
    }

    var frame = CGRect(origin: .zero, size: CGSize(width: staticContentView.bounds.width, height: 120))
    frame.origin.x = (staticContentView.bounds.width - frame.width) * 0.5
    frame.origin.y = (staticContentView.bounds.height - frame.height) * 0.5

    let container = UIView(frame: frame)

    let label = UILabel()
    label.textAlignment = .Center
    label.text = error?.localizedDescription ?? "No records found"
    label.sizeToFit()

    var labelFrame = label.frame
    labelFrame.origin.x = (container.bounds.width - label.bounds.width) * 0.5
    label.frame = labelFrame

    container.addSubview(label)

    return container
  }
}