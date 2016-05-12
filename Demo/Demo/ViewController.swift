//
//  ViewController.swift
//  Demo
//
//  Created by Tim on 12/05/2016.
//  Copyright © 2016 timominous. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var statefulTableView: StatefulTableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    statefulTableView.canPullToRefresh = true
    statefulTableView.statefulDelegate = self
    statefulTableView.tableDataSource = self
    statefulTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "identifier")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

}

extension UIViewController: StatefulTableDelegate {
  func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: InitialLoadCompletionHandler) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
    dispatch_after(time, dispatch_get_main_queue()) {
      handler(tableIsEmpty: true, errorOrNil: nil)
    }
  }

  func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: InitialLoadCompletionHandler) {

  }

  func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: LoadMoreCompletionHandler) {

  }

  func statefulTableViewViewForInitialLoad(tvc: StatefulTableView) -> UIView? {
    return nil
  }

  func statefulTableViewView(tvc: StatefulTableView, forInitialLoadError: NSError?) -> UIView? {
    return nil
  }

  func statefulTableViewView(tvc: StatefulTableView, forLoadMoreError: NSError?) -> UIView? {
    return nil
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCellWithIdentifier("identifier", forIndexPath: indexPath)
  }
}

