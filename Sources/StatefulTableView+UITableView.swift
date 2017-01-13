//
//  StatefulTableView+UITableView.swift
//  Pods
//
//  Created by Tim on 23/06/2016.
//
//

import UIKit

extension StatefulTableView {
  // MARK: - Configuring a Table View

  /**
   Returns the number of rows (table cells) in a specified section.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/numberOfRowsInSection:) for more details.
   */
  public func numberOfRowsInSection(_ section: Int) -> Int {
    return tableView.numberOfRows(inSection: section)
  }

  /**
   The number of sections in the table view. (read-only)

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/numberOfSections) for more details.
   */
  public var numberOfSections: Int {
    return tableView.numberOfSections
  }

  /**
   The height of each row (that is, table cell) in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/rowHeight) for more details
   */
  public var rowHeight: CGFloat {
    set { tableView.rowHeight = newValue }
    get { return tableView.rowHeight }
  }

  /**
   The style for table cells used as separators.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/separatorStyle) for more details.
   */
  public var separatorStyle: UITableViewCellSeparatorStyle {
    set { tableView.separatorStyle = newValue }
    get { return tableView.separatorStyle }
  }

  /**
   The color of separator rows in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/separatorColor) for more details.
   */
  public var separatorColor: UIColor? {
    set { tableView.separatorColor = newValue }
    get { return tableView.separatorColor }
  }

  /**
   The effect applied to table separators.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/separatorEffect) for more details.
   */
  @available(iOS 8.0, *)
  public var separatorEffect: UIVisualEffect? {
    set { tableView.separatorEffect = newValue }
    get { return tableView.separatorEffect }
  }

  /**
   Specifies the default inset of cell separators.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/separatorInset) for more details.
   */
  @available(iOS 7.0, *)
  public var separatorInset: UIEdgeInsets {
    set { tableView.separatorInset = newValue }
    get { return tableView.separatorInset }
  }

  /**
   A Boolean value that indicates whether the cell margins are derived from the width of the readable content guide.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/cellLayoutMarginsFollowReadableWidth) for more details.
   */
  @available(iOS 9.0, *)
  public var cellLayoutMarginsFollowReadableWidth: Bool {
    set { tableView.cellLayoutMarginsFollowReadableWidth = newValue }
    get { return tableView.cellLayoutMarginsFollowReadableWidth }
  }
}

extension StatefulTableView {
  // MARK: - Creating Table View Cells

  /**
   Registers a nib object containing a cell with the table view under a specified identifier.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/registerNib:forCellReuseIdentifier:) for more details.
   */
  @available(iOS 5.0, *)
  public func registerNib(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
    tableView.register(nib, forCellReuseIdentifier: identifier)
  }

  /**
   Registers a class for use in creating new table cells.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/registerClass:forCellReuseIdentifier:) for more details.
   */
  @available(iOS 6.0, *)
  public func registerClass(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
    tableView.register(cellClass, forCellReuseIdentifier: identifier)
  }

  /**
   Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/dequeueReusableCellWithIdentifier:forIndexPath:) for more details.
   */
  @available(iOS 6.0, *)
  public func dequeueReusableCellWithIdentifier(_ identifier: String, forIndexPath indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
  }

  /**
   Returns a reusable table-view cell object located by its identifier.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/dequeueReusableCellWithIdentifier:) for more details.
   */
  public func dequeueReusableCellWithIdentifier(_ identifier: String) -> UITableViewCell? {
    return tableView.dequeueReusableCell(withIdentifier: identifier)
  }
}

extension StatefulTableView {
  // MARK: - Accessing Header and Footer Views

  /**
   Registers a nib object containing a header or footer with the table view under a specified identifier.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/registerNib:forHeaderFooterViewReuseIdentifier:) for more details.
   */
  @available(iOS 6.0, *)
  public func registerNib(_ nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
    tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
  }

  /**
   Registers a class for use in creating new table header or footer views.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/registerClass:forHeaderFooterViewReuseIdentifier:) for more details.
   */
  @available(iOS 6.0, *)
  public func registerClass(_ aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
    tableView.register(aClass, forHeaderFooterViewReuseIdentifier: identifier)
  }

  /**
   Returns a reusable header or footer view located by its identifier.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/dequeueReusableHeaderFooterViewWithIdentifier:) for more details.
   */
  @available(iOS 6.0, *)
  public func dequeueReusableHeaderFooterViewWithIdentifier(_ identifier: String) -> UITableViewHeaderFooterView? {
    return tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
  }

  /**
   Returns an accessory view that is displayed above the table.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/tableHeaderView) for more details.
   */
  public var tableHeaderView: UIView? {
    set { tableView.tableHeaderView = newValue }
    get { return tableView.tableHeaderView }
  }

  /**
   Returns an accessory view that is displayed below the table.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/tableFooterView) for more details.
   */
  public var tableFooterView: UIView? {
    set { tableView.tableFooterView = newValue }
    get { return tableView.tableFooterView }
  }

  /**
   The height of section headers in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/sectionHeaderHeight) for more details.
   */
  public var sectionHeaderHeight: CGFloat {
    set { tableView.sectionHeaderHeight = newValue }
    get { return tableView.sectionHeaderHeight }
  }

  /**
   The height of section footers in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/sectionFooterHeight) for more details.
   */
  public var sectionFooterHeight: CGFloat {
    set { tableView.sectionFooterHeight = newValue }
    get { return tableView.sectionFooterHeight }
  }

  /**
   Returns the header view associated with the specified section.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/headerViewForSection:) for more details.
   */
  @available(iOS 6.0, *)
  public func headerViewForSection(_ section: Int) -> UITableViewHeaderFooterView? {
    return tableView.headerView(forSection: section)
  }

  /**
   Returns the footer view associated with the specified section.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/footerViewForSection:) for more details.
   */
  @available(iOS 6.0, *)
  public func footerViewForSection(_ section: Int) -> UITableViewHeaderFooterView? {
    return tableView.footerView(forSection: section)
  }
}

extension StatefulTableView {
  // MARK: - Accessing Cells and Sections

  /**
   Returns the table cell at the specified index path.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/cellForRowAtIndexPath:) for more details.
   */
  public func cellForRowAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell? {
    return tableView.cellForRow(at: indexPath)
  }

  /**
   Returns an index path representing the row and section of a given table-view cell.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/indexPathForCell:) for more details.
   */
  public func indexPathForCell(_ cell: UITableViewCell) -> IndexPath? {
    return tableView.indexPath(for: cell)
  }

  /**
   Returns an index path identifying the row and section at the given point.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/indexPathForRowAtPoint:) for more details.
   */
  public func indexPathForRowAtPoint(_ point: CGPoint) -> IndexPath? {
    return tableView.indexPathForRow(at: point)
  }

  /**
   An array of index paths each representing a row enclosed by a given rectangle.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/indexPathsForRowsInRect:) for more details.
   */
  public func indexPathsForRowsInRect(_ rect: CGRect) -> [IndexPath]? {
    return tableView.indexPathsForRows(in: rect)
  }

  /**
   The table cells that are visible in the table view. (read-only)

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/visibleCells) for more details.
   */
  public var visibleCells: [UITableViewCell] {
    return tableView.visibleCells
  }

  /**
   An array of index paths each identifying a visible row in the table view. (read-only)

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/indexPathsForVisibleRows) for more details.
   */
  public var indexPathsForVisibleRows: [IndexPath]? {
    return tableView.indexPathsForVisibleRows;
  }
}

extension StatefulTableView {
  // MARK: - Estimating Element Heights

  /**
   The estimated height of rows in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/estimatedRowHeight) for more details.
   */
  @available(iOS 7.0, *)
  public var estimatedRowHeight: CGFloat {
    set { tableView.estimatedRowHeight = newValue }
    get { return tableView.estimatedRowHeight }
  }

  /**
   The estimated height of section headers in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/estimatedSectionHeaderHeight) for more details.
   */
  @available(iOS 7.0, *)
  public var estimatedSectionHeaderHeight: CGFloat {
    set { tableView.estimatedSectionHeaderHeight = newValue }
    get { return tableView.estimatedSectionHeaderHeight }
  }

  /**
   The estimated height of section footers in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/estimatedSectionFooterHeight) for more details.
   */
  @available(iOS 7.0, *)
  public var estimatedSectionFooterHeight: CGFloat {
    set { tableView.estimatedSectionFooterHeight = newValue }
    get { return tableView.estimatedSectionHeaderHeight }
  }
}

extension StatefulTableView {
  // MARK: - Scrolling the Table View

  /**
   Scrolls through the table view until a row identified by index path is at a particular location on the screen.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/scrollToRowAtIndexPath:atScrollPosition:animated:) for more details.
   */
  public func scrollToRowAtIndexPath(_ indexPath: IndexPath, atScrollPosition scrollPosition: UITableViewScrollPosition, animated: Bool) {
    tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
  }

  /**
   Scrolls the table view so that the selected row nearest to a specified position in the table view is at that position.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/scrollToNearestSelectedRowAtScrollPosition:animated:) for more details.
   */
  public func scrollToNearestSelectedRowAtScrollPosition(_ scrollPosition: UITableViewScrollPosition, animated: Bool) {
    tableView.scrollToNearestSelectedRow(at: scrollPosition, animated: animated)
  }
}

extension StatefulTableView {
  // MARK: - Managing Selections

  /**
   An index path identifying the row and section of the selected row. (read-only)

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/indexPathForSelectedRow) for more details.
   */
  public var indexPathForSelectedRow: IndexPath? {
    return tableView.indexPathForSelectedRow
  }

  /**
   The index paths representing the selected rows. (read-only)

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/indexPathsForSelectedRows) for more details.
   */
  @available(iOS 5.0, *)
  public var indexPathsForSelectedRows: [IndexPath]? {
    return tableView.indexPathsForSelectedRows
  }

  /**
   Selects a row in the table view identified by index path, optionally scrolling the row to a location in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/selectRowAtIndexPath:animated:scrollPosition:) for more details.
   */
  public func selectRowAtIndexPath(_ indexPath: IndexPath?, animated: Bool, scrollPosition: UITableViewScrollPosition) {
    tableView.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
  }

  /**
   Deselects a given row identified by index path, with an option to animate the deselection.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/deselectRowAtIndexPath:animated:) for more details.
   */
  public func deselectRowAtIndexPath(_ indexPath: IndexPath, animated: Bool) {
    tableView.deselectRow(at: indexPath, animated: animated)
  }

  /**
   A Boolean value that determines whether users can select a row.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/allowsSelection) for more details.
   */
  @available(iOS 3.0, *)
  public var allowsSelection: Bool {
    set { tableView.allowsSelection = newValue }
    get { return tableView.allowsSelection }
  }

  /**
   A Boolean value that determines whether users can select more than one row outside of editing mode.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/allowsMultipleSelectionhttps://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/allowsMultipleSelection) for more details.
   */
  @available(iOS 5.0, *)
  public var allowsMultipleSelection: Bool {
    set { tableView.allowsMultipleSelection = newValue }
    get { return tableView.allowsMultipleSelection }
  }

  /**
   A Boolean value that determines whether users can select cells while the table view is in editing mode.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/allowsSelectionDuringEditing) for more details.
   */
  public var allowsSelectionDuringEditing: Bool {
    set { tableView.allowsSelectionDuringEditing = newValue }
    get { return tableView.allowsSelectionDuringEditing }
  }

  /**
   A Boolean value that controls whether users can select more than one cell simultaneously in editing mode.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/allowsMultipleSelectionDuringEditing) for more details.
   */
  @available(iOS 5.0, *)
  public var allowsMultipleSelectionDuringEditing: Bool {
    set { tableView.allowsMultipleSelectionDuringEditing = newValue }
    get { return tableView.allowsMultipleSelectionDuringEditing }
  }
}

extension StatefulTableView {
  // MARK: - Inserting, Deleting, and Moving Rows and Sections

  /**
   Begins a series of method calls that insert, delete, or select rows and sections of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/beginUpdates) for more details.
   */
  public func beginUpdates() {
    tableView.beginUpdates()
  }

  /**
   Concludes a series of method calls that insert, delete, select, or reload rows and sections of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/endUpdates) for more details.
   */
  public func endUpdates() {
    tableView.endUpdates()
  }

  /**
   Inserts rows in the table view at the locations identified by an array of index paths, with an option to animate the insertion.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/insertRowsAtIndexPaths:withRowAnimation:) for more details.
   */
  public func insertRowsAtIndexPaths(_ indexPaths: [IndexPath], withRowAnimation animation: UITableViewRowAnimation) {
    tableView.insertRows(at: indexPaths, with: animation)
  }

  /**
   Deletes the rows specified by an array of index paths, with an option to animate the deletion.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/deleteRowsAtIndexPaths:withRowAnimation:) for more details.
   */
  public func deleteRowsAtIndexPaths(_ indexPaths: [IndexPath], withRowAnimation animation: UITableViewRowAnimation) {
    tableView.deleteRows(at: indexPaths, with: animation)
  }

  /**
   Moves the row at a specified location to a destination location.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/moveRowAtIndexPath:toIndexPath:) for more details.
   */
  @available(iOS 5.0, *)
  public func moveRowAtIndexPath(_ indexPath: IndexPath, toIndexPath newIndexPath: IndexPath) {
    tableView.moveRow(at: indexPath, to: newIndexPath)
  }

  /**
   Inserts one or more sections in the table view, with an option to animate the insertion.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/insertSections:withRowAnimation:) for more details.
   */
  public func insertSections(_ sections: IndexSet, withRowAnimation animation: UITableViewRowAnimation) {
    tableView.insertSections(sections, with: animation)
  }

  /**
   Deletes one or more sections in the table view, with an option to animate the deletion.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/deleteSections:withRowAnimation:) for more details.
   */
  public func deleteSections(_ sections: IndexSet, withRowAnimation animation: UITableViewRowAnimation) {
    tableView.deleteSections(sections, with: animation)
  }

  /**
   Moves a section to a new location in the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/moveSection:toSection:) for more details.
   */
  @available(iOS 5.0, *)
  public func moveSection(_ section: Int, toSection newSection: Int) {
    tableView.moveSection(section, toSection: newSection)
  }
}

extension StatefulTableView {
  // MARK: - Managing the Editing of Table Cells

  /**
   A Boolean value that determines whether the table view is in editing mode.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/editing) for more details.
   */
  public var editing: Bool {
    set { tableView.isEditing = newValue }
    get { return tableView.isEditing }
  }

  /**
   Toggles the table view into and out of editing mode.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/setEditing:animated:) for more details.
   */
  public func setEditing(_ editing: Bool, animated: Bool) {
    tableView.setEditing(editing, animated: animated)
  }
}

extension StatefulTableView {
  // MARK: - Reloading the Table View

  /**
   Reloads the rows and sections of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/reloadData) for more details.
   */
  public func reloadData() {
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }

  /**
   Reloads the specified rows using an animation effect.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/reloadRowsAtIndexPaths:withRowAnimation:) for more details.
   */
  @available(iOS 3.0, *)
  public func reloadRowsAtIndexPaths(_ indexPaths: [IndexPath], withRowAnimation animation: UITableViewRowAnimation) {
    tableView.reloadRows(at: indexPaths, with: animation)
  }

  /**
   Reloads the specified sections using a given animation effect.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/reloadSections:withRowAnimation:) for more details.
   */
  @available(iOS 3.0, *)
  public func reloadSections(_ sections: IndexSet, withRowAnimation animation: UITableViewRowAnimation) {
    tableView.reloadSections(sections, with: animation)
  }

  /**
   Reloads the items in the index bar along the right side of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/reloadSectionIndexTitles) for more details.
   */
  @available(iOS 3.0, *)
  public func reloadSectionIndexTitles() {
    DispatchQueue.main.async {
      self.tableView.reloadSectionIndexTitles()
    }
  }
}

extension StatefulTableView {
  // MARK: - Accessing Drawing Areas of the Table View

  /**
   Returns the drawing area for a specified section of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/rectForSection:) for more details.
   */
  public func rectForSection(_ section: Int) -> CGRect {
    return tableView.rect(forSection: section)
  }

  /**
   Returns the drawing area for a row identified by index path.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/rectForRowAtIndexPath:) for more details.
   */
  public func rectForRowRowAtIndexPath(_ indexPath: IndexPath) -> CGRect {
    return tableView.rectForRow(at: indexPath)
  }

  /**
   Returns the drawing area for the footer of the specified section.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instm/UITableView/rectForFooterInSection:) for more details.
   */
  public func rectForFooterInSection(_ section: Int) -> CGRect {
    return tableView.rectForFooter(inSection: section)
  }

  /**
   Returns the drawing area for the header of the specified section.

   - Discussion: Visit this [link](Returns the drawing area for the header of the specified section.) for more details.
   */
  public func rectFotHeaderInSection(_ section: Int) -> CGRect {
    return tableView.rectForHeader(inSection: section)
  }
}

extension StatefulTableView {
  // MARK: - Managing the Delegate and the Data Source

  /**
   The object that acts as the data source of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/dataSource) for more details.
   */
  public var dataSource: UITableViewDataSource? {
    set { tableView.dataSource = newValue }
    get { return tableView.dataSource }
  }

  /**
   The object that acts as the delegate of the table view.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/delegate) for more details
   */
  public var delegate: UITableViewDelegate? {
    set { tableView.delegate = newValue }
    get { return tableView.delegate }
  }
}

extension StatefulTableView {
  // MARK: - Configuring the Table Index

  /**
   The number of table rows at which to display the index list on the right edge of the table.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/sectionIndexMinimumDisplayRowCount) for more details.
   */
  public var sectionIndexMinimumDisplayRowCount: Int {
    set { tableView.sectionIndexMinimumDisplayRowCount = newValue }
    get { return tableView.sectionIndexMinimumDisplayRowCount }
  }

  /**
   The color to use for the table view’s index text.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/sectionIndexColor) for more details.
   */
  @available(iOS 6.0, *)
  public var sectionIndexColor: UIColor? {
    set { tableView.sectionIndexColor = newValue }
    get { return tableView.sectionIndexColor }
  }

  /**
   The color to use for the background of the table view’s section index while not being touched.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/sectionIndexBackgroundColor) for more details.
   */
  @available(iOS 7.0, *)
  public var sectionIndexBackgroundColor: UIColor? {
    set { tableView.sectionIndexBackgroundColor = newValue }
    get { return tableView.sectionIndexBackgroundColor }
  }

  /**
   The color to use for the table view’s index background area.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/sectionIndexTrackingBackgroundColor) for more details.
   */
  @available(iOS 6.0, *)
  public var sectionIndexTrackingBackgroundColor: UIColor? {
    set { tableView.sectionIndexTrackingBackgroundColor = newValue }
    get { return tableView.sectionIndexTrackingBackgroundColor }
  }
}

extension StatefulTableView {
  // MARK: - Managing Focus

  /**
   A Boolean value that indicates whether the table view should automatically return the focus to the cell at the last focused index path.

   - Discussion: Visit this [link](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/#//apple_ref/occ/instp/UITableView/remembersLastFocusedIndexPath) for more details.
   */
  @available(iOS 9.0, *)
  public var remembersLastFocusedIndexPath: Bool {
    set { tableView.remembersLastFocusedIndexPath = newValue }
    get { return tableView.remembersLastFocusedIndexPath }
  }
}
