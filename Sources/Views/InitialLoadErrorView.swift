//
//  InitialLoadErrorView.swift
//  StatefulTableView
//
//  Created by iomusashi on 05/10/2018.
//

import UIKit

/**
 This UIView subclass serves as the default errorview when an initial load fails.
 
 You can customise the label and button properties of this class, or use it as is.
 */
public protocol InitialLoadErrorViewDelegate {
  
  func initialLoadErrorView(_ errorView: InitialLoadErrorView, didTapErrorButton: UIButton)
}

public class InitialLoadErrorView: UIView {

  public var error: NSError? = nil
  public var label: UILabel? = nil
  public var button: UIButton? = nil
  public var delegate: InitialLoadErrorViewDelegate? = nil
  
  // MARK: Constructors
  public convenience init(error: NSError?, delegate: InitialLoadErrorViewDelegate?) {
    self.init(frame: .zero)
    self.error = error
    self.delegate = delegate
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.error = nil
    self.delegate = nil
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.error = nil
    self.delegate = nil
  }
  
  // MARK: Layout subviews
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    let centered = constrainedContainerView()
    var centeredSize: CGSize = .zero
    
    let label = constrainedLabel()
    self.label = label
    centered.addSubview(label)
    apply([.top, .centerX], ofView: label, toView: centered)
    centeredSize.width = label.bounds.width
    centeredSize.height = label.bounds.height
    
    if let _ = error {
      let button = constrainedButton()
      centeredSize.width = max(centeredSize.width, button.bounds.width)
      centeredSize.height = label.bounds.height + button.bounds.height + 5
      centered.addSubview(button)
      apply([.bottom, .centerX], ofView: button, toView: centered)
    }
    centered.setWidthConstraint(centeredSize.width)
    centered.setHeightConstraint(centeredSize.height)

    let container = constrainedContainerView()
    container.frame = self.bounds
    container.addSubview(centered)
    centerView(centered, inContainer: container)
    addSubview(container)
    pinView(container, toContainer: self)
  }
  
  @objc
  internal func didTapErrorButton(_ sender: UIButton) {
    delegate?.initialLoadErrorView(self, didTapErrorButton: sender)
  }
  
  fileprivate func constrainedContainerView() -> UIView {
    let containerView = UIView(frame: .zero)
    containerView.translatesAutoresizingMaskIntoConstraints = false
    return containerView
  }
  
  fileprivate func constrainedLabel() -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.text = error?.localizedDescription ?? "No items founds."
    label.sizeToFit()
    label.setWidthConstraintToCurrent()
    label.setHeightConstraintToCurrent()
    return label
  }
  
  fileprivate func constrainedButton() -> UIButton {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Try Again", for: UIControl.State())
    button.addTarget(self, action: #selector(didTapErrorButton(_:)), for: .touchUpInside)
    button.sizeToFit()
    
    button.setWidthConstraintToCurrent()
    button.setHeightConstraintToCurrent()
    return button
  }
}
