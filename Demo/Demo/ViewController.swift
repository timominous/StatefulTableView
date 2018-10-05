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

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    statefulTableView.triggerInitialLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

}

extension ViewController: StatefulTableDelegate {

  func statefulTable(_ tableView: StatefulTableView, pullToRefreshCompletion completion: @escaping InitialLoadCompletion) {
    items = Int(arc4random_uniform(15))
    let empty = items == 0
    
    let time = DispatchTime.now() + Double(Int64(3 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
      let error = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
      tableView.reloadData()
      completion(empty, error)
    }
  }
  
  func statefulTable(_ tableView: StatefulTableView, initialLoadCompletion completion: @escaping InitialLoadCompletion) {
    items = Int(arc4random_uniform(15))
    let empty = items == 0
    
    let time = DispatchTime.now() + Double(Int64(3 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
      let error = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
      tableView.reloadData()
      completion(empty, error)
    }
  }
  
  func statefulTable(_ tableView: StatefulTableView, loadMoreCompletion completion: @escaping LoadMoreCompletion) {
    items += Int(arc4random_uniform(20))
    let loadMore = items < 50
    
    let time = DispatchTime.now() + Double(Int64(3 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
      let error = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
      tableView.reloadData()
      completion(loadMore, error, !loadMore)
    }
  }
  
  // Uncomment to use a custom initial loading view
//  func statefulTable(_ tableView: StatefulTableView,
//                     viewForInitialLoad defaultView: UIActivityIndicatorView) -> UIView? {
//
//    return defaultView
//  }
  
  // Uncomment to use a custom initial loading error view
//  func statefulTable(_ tableView: StatefulTableView,
//                     initialLoadWithError errorOrNil: NSError?,
//                     errorView: InitialLoadErrorView) -> UIView? {
//
//    return errorView
//  }

  // Uncommen to use a custom load more error view
//  func statefulTable(_ tableView: StatefulTableView,
//                     loadMoreWithError: NSError?,
//                     errorView: LoadMoreErrorView) -> UIView? {
//
//    return errorView
//  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath)
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.textLabel?.text = "Cell \(indexPath.row)"
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    statefulTableView.scrollViewDidScroll(scrollView)
  }
}

