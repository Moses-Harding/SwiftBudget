//
//  DismissView.swift
//  SwiftBudget
//
//  Created by Moses Harding on 11/1/20.
//

import Foundation
import Cocoa

class DismissView: NSView {
    
    var xOutButton = NSButton(image: NSImage(byReferencingFile: "X.png")!, target: self, action: #selector(xOut))
    var mainBlock = NSView()
    
    
    init() {
        super.init(frame: CGRect.zero)
        let leftView = NSView()
        let rightView = NSView()
        
        let labelView = NSTextField(string: "Uber")
        
        leftView.addSubview(labelView)
        
        let contentStack = NSStackView(views: [leftView, rightView])
        
        self.addSubview(contentStack)
        
        self.frame = CGRect(origin: CGPoint(x: 500, y: 500), size: CGSize(width: 100, height: 50))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func xOut() {
        print("X out")
    }
}
