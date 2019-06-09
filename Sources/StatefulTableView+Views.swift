//
//  StatefulTableView+Views.swift
//  Pods
//
//  Created by Tim on 23/06/2016.
//
//

import UIKit

extension StatefulTableView {
  // MARK: - Views

  internal func resetdynamicContentView(withChildView childView: UIView?) {
    dynamicContentView.subviews.forEach { $0.removeFromSuperview() }

    guard let childView = childView else { return }

    dynamicContentView.addSubview(childView)

    childView.translatesAutoresizingMaskIntoConstraints = false

    pinView(childView, toContainer: dynamicContentView)
  }

  internal var viewForInitialLoad: UIView? {
    let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    activityIndicatorView.startAnimating()
    guard let statefulDelegate = statefulDelegate else {
      return activityIndicatorView
    }
    return statefulDelegate.statefulTable(self, viewForInitialLoad: activityIndicatorView)
  }

  internal func viewForEmptyInitialLoad(withError error: NSError?) -> UIView? {
    let errorView = InitialLoadErrorView(error: error, delegate: self)
    guard let statefulDelegate = statefulDelegate else {
      return errorView
    }
    return statefulDelegate.statefulTable(self, initialLoadWithError: error, errorView: errorView)
  }
  
  internal func viewForLoadingMore(withError error: NSError?) -> UIView? {
    let errorView = LoadMoreErrorView(error: error)
    guard let statefulDelegate = statefulDelegate else {
      return errorView
    }
    return statefulDelegate.statefulTable(self, loadMoreWithError: error, errorView: errorView)
  }
}

extension StatefulTableView: InitialLoadErrorViewDelegate {
  
  public func initialLoadErrorView(_ errorView: InitialLoadErrorView, didTapErrorButton: UIButton) {
    triggerInitialLoad()
  }
}

internal extension UIView {
  
  func pinView(_ view: UIView, toContainer container: UIView) {
    let attributes: [NSLayoutConstraint.Attribute] = [.top, .bottom, .leading, .trailing]
    apply(attributes, ofView: view, toView: container)
  }
  
  func centerView(_ view: UIView, inContainer container: UIView) {
    let attributes: [NSLayoutConstraint.Attribute] = [.centerX, .centerY]
    apply(attributes, ofView: view, toView: container)
  }
  
  func centerViewHorizontally(_ view: UIView, inContainer container: UIView) {
    apply([.centerX], ofView: view, toView: container)
  }
  
  func centerViewVertically(_ view: UIView, inContainer container: UIView) {
    apply([.centerY], ofView: view, toView: container)
  }
  
  func apply(_ attributes: [NSLayoutConstraint.Attribute], ofView childView: UIView, toView containerView: UIView) {
    let constraints = attributes.map {
      return NSLayoutConstraint(item: childView, attribute: $0, relatedBy: .equal,
                                toItem: containerView, attribute: $0, multiplier: 1, constant: 0)
    }
    containerView.addConstraints(constraints)
  }
  
  func setWidthConstraintToCurrent() {
    setWidthConstraint(bounds.width)
  }

  func setHeightConstraintToCurrent() {
    setHeightConstraint(bounds.height)
  }

  func setWidthConstraint(_ width: CGFloat) {
    addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil,
      attribute: .notAnAttribute, multiplier: 1, constant: width))
  }

  func setHeightConstraint(_ height: CGFloat) {
    addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil,
      attribute: .notAnAttribute, multiplier: 1, constant: height))
  }
}
