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

  internal func resetStaticContentView(withChildView childView: UIView?) {
    staticContentView.subviews.forEach { $0.removeFromSuperview() }

    guard let childView = childView else { return }

    staticContentView.addSubview(childView)

    childView.translatesAutoresizingMaskIntoConstraints = false

    pinView(childView, toContainer: staticContentView)
  }

  internal var viewForInitialLoad: UIView? {
    if let delegateMethod = statefulDelegate?.statefulTableViewViewForInitialLoad {
      return delegateMethod(self)
    }

    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    activityIndicatorView.startAnimating()

    return activityIndicatorView
  }

  internal func viewForEmptyInitialLoad(withError error: NSError?) -> UIView? {
    if let delegateMethod = statefulDelegate?.statefulTableViewInitialErrorView {
      return delegateMethod(self, forInitialLoadError: error)
    }

    let container = UIView(frame: .zero)

    var centeredSize: CGSize = .zero

    let centered = UIView(frame: .zero)
    centered.translatesAutoresizingMaskIntoConstraints = false

    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .Center
    label.text = error?.localizedDescription ?? "No records found"
    label.sizeToFit()

    label.setWidthConstraintToCurrent()
    label.setHeightConstraintToCurrent()

    centered.addSubview(label)

    apply([.Top, .CenterX], ofView: label, toView: centered)

    centeredSize.width = label.bounds.width
    centeredSize.height = label.bounds.height

    if let _ = error {
      let button = UIButton(type: .System)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setTitle("Try Again", forState: .Normal)
      button.addTarget(self, action: #selector(triggerInitialLoad(_:)), forControlEvents: .TouchUpInside)
      button.sizeToFit()

      button.setWidthConstraintToCurrent()
      button.setHeightConstraintToCurrent()

      centeredSize.width = max(centeredSize.width, button.bounds.width)
      centeredSize.height = label.bounds.height + button.bounds.height + 5

      centered.addSubview(button)

      apply([.Bottom, .CenterX], ofView: button, toView: centered)
    }

    centered.setWidthConstraint(centeredSize.width)
    centered.setHeightConstraint(centeredSize.height)

    container.addSubview(centered)

    centerView(centered, inContainer: container)

    return container
  }
}

internal extension StatefulTableView {
  // MARK: - Helpers

  internal func pinView(view: UIView, toContainer container: UIView) {
    let attributes: [NSLayoutAttribute] = [.Top, .Bottom, .Leading, .Trailing]
    apply(attributes, ofView: view, toView: container)
  }

  internal func centerView(view: UIView, inContainer container: UIView) {
    let attributes: [NSLayoutAttribute] = [.CenterX, .CenterY]
    apply(attributes, ofView: view, toView: container)
  }

  internal func centerViewHorizontally(view: UIView, inContainer container: UIView) {
    apply([.CenterX], ofView: view, toView: container)
  }

  internal func centerViewVertically(view: UIView, inContainer container: UIView) {
    apply([.CenterY], ofView: view, toView: container)
  }

  internal func apply(attributes: [NSLayoutAttribute], ofView childView: UIView, toView containerView: UIView) {
    let constraints = attributes.map {
      return NSLayoutConstraint(item: childView, attribute: $0, relatedBy: .Equal,
        toItem: containerView, attribute: $0, multiplier: 1, constant: 0)
    }

    containerView.addConstraints(constraints)
  }
}

internal extension UIView {
  internal func setWidthConstraintToCurrent() {
    setWidthConstraint(bounds.width)
  }

  internal func setHeightConstraintToCurrent() {
    setHeightConstraint(bounds.height)
  }

  internal func setWidthConstraint(width: CGFloat) {
    addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil,
      attribute: .NotAnAttribute, multiplier: 1, constant: width))
  }

  internal func setHeightConstraint(height: CGFloat) {
    addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil,
      attribute: .NotAnAttribute, multiplier: 1, constant: height))
  }
}