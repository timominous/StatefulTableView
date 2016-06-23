//
//  StatefulTableView+LoadMore.swift
//  Pods
//
//  Created by Tim on 23/06/2016.
//
//

import UIKit

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

  internal func updateLoadMoreView() {
    if watchForLoadMore || lastLoadMoreError != nil {
      tableView.tableFooterView = viewForLoadingMore(withError: (loadMoreViewIsErrorView ? lastLoadMoreError : nil))
    } else {
      tableView.tableFooterView = UIView()
    }
  }

  internal func viewForLoadingMore(withError error: NSError?) -> UIView? {
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

  internal func setHasFinishedLoadingMore(canLoadMore: Bool, error: NSError?, showErrorView: Bool) {
    guard state == .LoadingMore else { return }

    self.canLoadMore = canLoadMore
    loadMoreViewIsErrorView = (error != nil) && showErrorView
    lastLoadMoreError = error

    setState(.Idle)
  }

  internal func watchForLoadMoreIfApplicable(watch: Bool) {
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

  internal func triggerLoadMoreIfApplicable(scrollView: UIScrollView) {
    guard watchForLoadMore && !loadMoreViewIsErrorView else { return }

    let scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y
    if scrollPosition < loadMoreTriggerThreshold {
      triggerLoadMore()
    }
  }
}
