//
//  StatefulTableView+State.swift
//  Pods
//
//  Created by Tim on 23/06/2016.
//
//

import Foundation

extension StatefulTableView {
  // MARK: - States
  
  internal func setState(_ newState: State) {
    setState(newState, updateView: true, error: nil)
  }
  
  internal func setState(_ newState: State, error: NSError?) {
    setState(newState, updateView: true, error: error)
  }
  
  internal func setState(_ newState: State, updateView: Bool, error: NSError?) {
    state = newState
    
    switch state {
    case .initialLoading:
      resetdynamicContentView(withChildView: viewForInitialLoad)
    case .emptyOrInitialLoadError:
      resetdynamicContentView(withChildView: viewForEmptyInitialLoad(withError: error))
    default: break
    }
    
    switch state {
    case .idle:
      watchForLoadMoreIfApplicable(true)
    case .emptyOrInitialLoadError:
      watchForLoadMoreIfApplicable(false)
    default: break
    }
    
    if updateView {
      let mode: ViewMode
      
      switch state {
      case .initialLoading: fallthrough
      case .emptyOrInitialLoadError:
        mode = .static
      default: mode = .table
      }
      
      viewMode = mode
    }
  }
}
