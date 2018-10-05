//
//  StatefulTableView+InitialLoad.swift
//  Pods
//
//  Created by Tim on 23/06/2016.
//
//

import UIKit

extension StatefulTableView {
  // MARK: - Initial load

  /**
   Triggers initial load of data programatically. Defaults to hiding the tableView.

   - returns: Boolean for success status.
   */
  @discardableResult
  @objc
  public func triggerInitialLoad() -> Bool {
    return triggerInitialLoad(false)
  }

  /**
   Triggers initial load of data programatically.

   - parameter shouldShowTableView: Control if the container should show the tableView or not.

   - returns: Boolean for success status.
   */
  @discardableResult
  @objc
  public func triggerInitialLoad(_ shouldShowTableView: Bool) -> Bool {
    guard !state.isLoading else { return false }

    if shouldShowTableView {
      self.setState(.initialLoadingTableView)
    } else {
      self.setState(.initialLoading)
    }

    guard let delegate = statefulDelegate else { return true }
    delegate.statefulTable(self, initialLoadCompletion: { [weak self] isEmpty, errorOrNil in
      DispatchQueue.main.async(execute: {
        self?.setHasFinishedInitialLoad(isEmpty, error: errorOrNil)
      })
    })
    return true
  }

  fileprivate func setHasFinishedInitialLoad(_ tableIsEmpty: Bool, error: NSError?) {
    guard state.isInitialLoading else { return }

    if tableIsEmpty {
      self.setState(.emptyOrInitialLoadError, updateView: true, error: error)
    } else {
      self.setState(.idle)
    }
  }
}
