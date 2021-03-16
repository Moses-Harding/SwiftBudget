//
//  Extensions.swift
//  SwiftBudget
//
//  Created by Moses Harding on 11/1/20.
//

import Foundation
import AppKit

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}



func hexToNSColor(from hexString: String, alpha: CGFloat = 1) -> NSColor {
    var splitString = ""
    var index = 0
    
    for char in Array(hexString) {
        index += 1
        splitString += String(char)
        if index % 2 == 0 {
            splitString += "|"
        }
    }

    let splitList = splitString.split(separator: "|")

    var floatList = [Int]()

    splitList.forEach { floatList.append(Int($0, radix: 16) ?? 0) }
    
    //print(floatList)
    
    //let color = CGColor(red: , green: splitList[1], blue: splitList[2], alpha: withAlpha)
    
    //let color = CGColor(red: floatList[0], green: floatList[1], blue: floatList[2], alpha: alpha)
    
    return NSColor(red: CGFloat(floatList[0] / 256), green: CGFloat(floatList[1] / 256), blue: CGFloat(floatList[2] / 256), alpha: alpha)
}


extension NSView {

    var backgroundColor: NSColor? {

        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }

        set {

            DispatchQueue.main.async {

                self.wantsLayer = true
                self.layer?.backgroundColor = newValue?.cgColor

            }

        }
    }
}
