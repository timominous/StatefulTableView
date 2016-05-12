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
  }

  lazy var tableView = UITableView()
  lazy var staticContentView: UIView = { [unowned self] in
    let view = UIView(frame: self.bounds)
    view.hidden = true
    return view
  }()

  var canPullToRefresh = false
  var canLoadMore = false
  var loadMoreTriggerThreshold = 64

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
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    tableView.frame = bounds
    staticContentView.frame = bounds
  }
}