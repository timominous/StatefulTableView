//
//  LoadMoreErrorView.swift
//  StatefulTableView
//
//  Created by iomusashi on 05/10/2018.
//

import UIKit

/**
 This UIView subclass serves as the default errorview when `loading more` item fail.
 
 You can customise the label and button properties of this class, or use it as is.
 */
public class LoadMoreErrorView: UIView {
  
  public var error: NSError? = nil
  
  // When error is non-nil:
  public var label: UILabel? = nil
  
  // When error is nil:
  public var activityIndicator: UIActivityIndicatorView? = nil
  
  // MARK: Constructors
  public convenience init(error: NSError?) {
    let frameSize = CGSize(width: UIScreen.main.bounds.size.width,
                           height: 44)
    self.init(frame: CGRect(origin: .zero, size: frameSize))
    self.error = error
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.error = nil
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.error = nil
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    let frameSize = CGSize(width: UIScreen.main.bounds.size.width,
                           height: 44)
    let container = UIView(frame: CGRect(origin: .zero,
                                         size: frameSize))
    let sub: UIView
    
    if let error = error {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.text = error.localizedDescription
      label.font = UIFont.systemFont(ofSize: 12)
      label.textAlignment = .center
      label.sizeToFit()
      self.label = label
      self.activityIndicator = nil
      sub = label
    } else {
      let activityIndicator = UIActivityIndicatorView(style: .gray)
      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      activityIndicator.startAnimating()
      activityIndicator.sizeToFit()
      self.activityIndicator = activityIndicator
      self.label = nil
      sub = activityIndicator
    }
    container.addSubview(sub)
    centerView(sub, inContainer: container)
    setHeightConstraint(44.0)
    addSubview(container)
  }
}
