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

    setState(.loadingMore)

    guard let delegate = statefulDelegate else { return }
    delegate.statefulTable(self, loadMoreCompletion: { [weak self] canLoadMore, errorOrNil, showErrorView in
      DispatchQueue.main.async(execute: {
        self?.setHasFinishedLoadingMore(canLoadMore, error: errorOrNil, showErrorView: showErrorView)
      })
    })
  }

  internal func updateLoadMoreView() {
    if watchForLoadMore || lastLoadMoreError != nil {
      tableView.tableFooterView = viewForLoadingMore(withError: (loadMoreViewIsErrorView ? lastLoadMoreError : nil))
    } else {
      tableView.tableFooterView = UIView()
    }
  }

  internal func setHasFinishedLoadingMore(_ canLoadMore: Bool, error: NSError?, showErrorView: Bool) {
    guard state == .loadingMore else { return }

    self.canLoadMore = canLoadMore
    loadMoreViewIsErrorView = (error != nil) && showErrorView
    lastLoadMoreError = error

    setState(.idle)
  }

  internal func watchForLoadMoreIfApplicable(_ watch: Bool) {
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
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    triggerLoadMoreIfApplicable(scrollView)
  }

  internal func triggerLoadMoreIfApplicable(_ scrollView: UIScrollView) {
    guard watchForLoadMore && !loadMoreViewIsErrorView else { return }

    let scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y
    if scrollPosition < loadMoreTriggerThreshold {
      triggerLoadMore()
    }
  }
}
