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
    if let delegateMethod = statefulDelegate?.statefulTableViewViewForInitialLoad {
      return delegateMethod(self)
    }

    let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    activityIndicatorView.startAnimating()

    return activityIndicatorView
  }

  internal func viewForEmptyInitialLoad(withError error: NSError?) -> UIView? {
    if let delegateMethod = statefulDelegate?.statefulTableViewInitialErrorView {
      return delegateMethod(self, error)
    }

    let container = UIView(frame: .zero)

    var centeredSize: CGSize = .zero

    let centered = UIView(frame: .zero)
    centered.translatesAutoresizingMaskIntoConstraints = false

    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.text = error?.localizedDescription ?? "No \(pluralType) found."
    label.sizeToFit()

    label.setWidthConstraintToCurrent()
    label.setHeightConstraintToCurrent()

    centered.addSubview(label)

    apply([.top, .centerX], ofView: label, toView: centered)

    centeredSize.width = label.bounds.width
    centeredSize.height = label.bounds.height

    if let _ = error {
      let button = UIButton(type: .system)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setTitle("Try Again", for: UIControl.State())
      button.addTarget(self, action: #selector(triggerInitialLoad(_:)), for: .touchUpInside)
      button.sizeToFit()

      button.setWidthConstraintToCurrent()
      button.setHeightConstraintToCurrent()

      centeredSize.width = max(centeredSize.width, button.bounds.width)
      centeredSize.height = label.bounds.height + button.bounds.height + 5

      centered.addSubview(button)

      apply([.bottom, .centerX], ofView: button, toView: centered)
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
}

internal extension UIView {
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
