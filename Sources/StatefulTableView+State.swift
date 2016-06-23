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
  
  internal func setState(newState: State) {
    setState(newState, updateView: true, error: nil)
  }
  
  internal func setState(newState: State, error: NSError?) {
    setState(newState, updateView: true, error: error)
  }
  
  internal func setState(newState: State, updateView: Bool, error: NSError?) {
    state = newState
    
    switch state {
    case .InitialLoading:
      resetStaticContentView(withChildView: viewForInitialLoad)
    case .EmptyOrInitialLoadError:
      resetStaticContentView(withChildView: viewForEmptyInitialLoad(withError: error))
    default: break
    }
    
    switch state {
    case .Idle:
      watchForLoadMoreIfApplicable(true)
    case .EmptyOrInitialLoadError:
      watchForLoadMoreIfApplicable(false)
    default: break
    }
    
    if updateView {
      let mode: ViewMode
      
      switch state {
      case .InitialLoading: fallthrough
      case .EmptyOrInitialLoadError:
        mode = .Static
      default: mode = .Table
      }
      
      viewMode = mode
    }
  }
}