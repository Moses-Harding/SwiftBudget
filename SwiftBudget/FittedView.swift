//
//  FittedView.swift
//  SwiftBudget
//
//  Created by Moses Harding on 11/1/20.
//

import Foundation
import AppKit

enum ConstraintType {
    case fitted, layoutGuides, padded, splitLeft, splitRight, quarterLeft, top, middle, bottom
}

class FittedView: NSView {
    
    var parentView: NSView!
    
    init(parent: NSView, fitType: ConstraintType = .fitted, padding: CGFloat = 0.0)  {
        
        super.init(frame: CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        parentView = parent
        
        parent.addSubview(self)
        //let layoutMargins = parent.layoutGuides
        
        var constraints: [NSLayoutConstraint]!
        
        switch fitType {
        case .padded:
            constraints = [
                self.topAnchor.constraint(equalTo: parent.topAnchor, constant: padding),
                self.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: padding),
                self.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -padding),
                self.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -padding)
            ]
        case .splitLeft:
            constraints = [
                self.topAnchor.constraint(equalTo: parent.topAnchor, constant: padding),
                self.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: padding),
                self.trailingAnchor.constraint(equalTo: parent.centerXAnchor),
                self.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -padding)
            ]
        case .splitRight:
            constraints = [
                self.topAnchor.constraint(equalTo: parent.topAnchor, constant: padding),
                self.leadingAnchor.constraint(equalTo: parent.centerXAnchor),
                self.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -padding),
                self.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -padding)
            ]
        case .quarterLeft:
            constraints = [
                self.topAnchor.constraint(equalTo: parent.topAnchor, constant: padding),
                self.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 5 * padding),
                self.trailingAnchor.constraint(equalTo: parent.centerXAnchor, constant: 5 * padding),
                self.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -padding)
            ]
        case .fitted:
            constraints = [
                self.topAnchor.constraint(equalTo: parent.topAnchor),
                self.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
                self.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
            ]
        default:
            constraints = [
                self.topAnchor.constraint(equalTo: parent.topAnchor),
                self.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
                self.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
            ]
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
