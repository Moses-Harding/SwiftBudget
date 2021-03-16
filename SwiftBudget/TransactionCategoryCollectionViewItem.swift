//  TransactionCategoryItem.swift
//  SwiftBudget
//
//  Created by Moses Harding on 11/1/20.
//

import Foundation
import Cocoa

class TransactionCategoryItem: NSCollectionViewItem {

    override func loadView() {
      self.view = NSView()
      self.view.wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
