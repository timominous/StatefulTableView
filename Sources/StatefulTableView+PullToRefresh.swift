//
//  StatefulTableView+PullToRefresh.swift
//  Pods
//
//  Created by Tim on 23/06/2016.
//
//

import UIKit

extension StatefulTableView {
    // MARK: - Pull to refresh
    
    @objc
    func refreshControlValueChanged() {
        if state != .loadingFromPullToRefresh && !state.isLoading {
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
    @discardableResult public func triggerPullToRefresh() -> Bool {
        guard !state.isLoading && canPullToRefresh else { return false }
        
        self.setState(.loadingFromPullToRefresh, updateView: false, error: nil)
        
        if let delegate = statefulDelegate {
            delegate.statefulTableViewWillBeginLoadingFromRefresh(tvc: self, handler: { [weak self](tableIsEmpty, errorOrNil) in
                DispatchQueue.main.async(execute: {
                    self?.setHasFinishedLoadingFromPullToRefresh(tableIsEmpty, error: errorOrNil)
                })
            })
        }
        
        beginRefreshingTableView()
        
        return true
    }
    
    
    fileprivate func beginRefreshingTableView() {
        refreshControl.beginRefreshing()
        if (self.tableView.contentOffset.y == 0) {
            UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState) {[weak self] in
                guard let self = self else { return }
                self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height)
            }
        }
    }
    
    fileprivate func setHasFinishedLoadingFromPullToRefresh(_ tableIsEmpty: Bool, error: NSError?) {
        guard state == .loadingFromPullToRefresh else { return }
        
        refreshControl.endRefreshing()
        
        if tableIsEmpty {
            self.setState(.emptyOrInitialLoadError, updateView: true, error: error)
        } else {
            self.setState(.idle)
        }
    }
}
