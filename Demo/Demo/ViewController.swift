//
//  ViewController.swift
//  Demo
//
//  Created by Tim on 12/05/2016.
//  Copyright © 2016 timominous. All rights reserved.
//

import UIKit
import StatefulTableView

class ViewController: UIViewController {

  @IBOutlet weak var statefulTableView: StatefulTableView!

  var items = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    statefulTableView.canPullToRefresh = true
    statefulTableView.canLoadMore = true

    statefulTableView.statefulDelegate = self
    statefulTableView.dataSource = self
    statefulTableView.delegate = self
    statefulTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "identifier")
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    statefulTableView.triggerInitialLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

}

extension ViewController: StatefulTableDelegate {
  func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: InitialLoadCompletionHandler) {
    items = Int(arc4random_uniform(15))
    let empty = items == 0

    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
    dispatch_after(time, dispatch_get_main_queue()) {
      let error = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
      tvc.reloadData()
      handler(tableIsEmpty: empty, errorOrNil: error)
    }
  }

  func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: InitialLoadCompletionHandler) {
    items = Int(arc4random_uniform(15))
    let empty = items == 0

    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
    dispatch_after(time, dispatch_get_main_queue()) {
      let error = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
      tvc.reloadData()
      handler(tableIsEmpty: empty, errorOrNil: error)
    }
  }

  func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: LoadMoreCompletionHandler) {
    items += Int(arc4random_uniform(20))
    let loadMore = items < 50

    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
    dispatch_after(time, dispatch_get_main_queue()) {
      let error = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
      tvc.reloadData()
      handler(canLoadMore: loadMore, errorOrNil: error, showErrorView: !loadMore)
    }
  }

  // Uncomment to use a custom initial loading view
//  func statefulTableViewViewForInitialLoad(tvc: StatefulTableView) -> UIView? {
//    let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
//    view.backgroundColor = .blueColor()
//    return view
//  }

  // Uncomment to use a custom initial loading error view
//  func statefulTableViewInitialErrorView(tvc: StatefulTableView, forInitialLoadError: NSError?) -> UIView? {
//  let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
//  view.backgroundColor = .redColor()
//  return view
//  }

  // Uncommen to use a custom load more error view
//  func statefulTableViewLoadMoreErrorView(tvc: StatefulTableView, forLoadMoreError: NSError?) -> UIView? {
//    let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
//    view.backgroundColor = .greenColor()
//    return view
//  }
}

extension ViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCellWithIdentifier("identifier", forIndexPath: indexPath)
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.textLabel?.text = "Cell \(indexPath.row)"
  }

  func scrollViewDidScroll(scrollView: UIScrollView) {
    statefulTableView.scrollViewDidScroll(scrollView)
  }
}

