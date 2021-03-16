//
//  TransactionCategoryExclusion.swift
//  SwiftBudget
//
//  Created by Moses Harding on 11/3/20.
//

import Foundation
import AppKit

class TransactionCategoryExclusion {
    
    var name: String
    var transactionCategory: TransactionCategory
    var itemNumber: Int
    var item: TransactionCategoryItem?
    
    init(name: String, transactionCategory: TransactionCategory, itemNumber: Int) {
        self.name = name
        self.transactionCategory = transactionCategory
        self.itemNumber = itemNumber
    }
}


class TransactionCategoryContainer {
    
    //ExclusionsStrings
    var necessitiesExclusions = [TransactionCategoryExclusion]()
    var financialExclusions = [TransactionCategoryExclusion]()
    var groceriesExclusions = [TransactionCategoryExclusion]()
    var alcoholExclusions = [TransactionCategoryExclusion]()
    var eatingOutExclusions = [TransactionCategoryExclusion]()
    var entertainmentExclusions = [TransactionCategoryExclusion]()
    var transportationExclusions = [TransactionCategoryExclusion]()
    
    var allLists = [[TransactionCategoryExclusion]]()
    
    var view: ViewController!
    
    var itemNumber = 0
    
    init(view: ViewController) {
        self.view = view
        
        readCategories()
    }
    
    func writeCategories() {
        
        var necessitiesString = ""
        var financialString = ""
        var groceriesString = ""
        var alcoholString = ""
        var eatingOutString = ""
        var entertainmentString = ""
        var transportationString = ""
        
        necessitiesExclusions.forEach { necessitiesString += $0.name }
        financialExclusions.forEach { financialString += $0.name }
        groceriesExclusions.forEach { groceriesString += $0.name }
        alcoholExclusions.forEach { alcoholString += $0.name }
        eatingOutExclusions.forEach { eatingOutString += $0.name }
        entertainmentExclusions.forEach { entertainmentString += $0.name }
        transportationExclusions.forEach { transportationString += $0.name }
        
        view.writeToFile(folder: "Support Data/", fileName: "Necessities", content: necessitiesString)
        view.writeToFile(folder: "Support Data/", fileName: "Financial", content: financialString)
        view.writeToFile(folder: "Support Data/", fileName: "Groceries", content: groceriesString)
        view.writeToFile(folder: "Support Data/", fileName: "Alcohol", content: alcoholString)
        view.writeToFile(folder: "Support Data/", fileName: "EatingOut", content: eatingOutString)
        view.writeToFile(folder: "Support Data/", fileName: "Entertainment", content: entertainmentString)
        view.writeToFile(folder: "Support Data/", fileName: "Transportation", content: transportationString)
    }
    
    func readCategories() {
        
        let necessitiesString = view.readFile(folder: "Support Data/", fileName: "Necessities").split(separator: ",")
        let financialString = view.readFile(folder: "Support Data/", fileName: "Financial").split(separator: ",")
        let groceriesString = view.readFile(folder: "Support Data/", fileName: "Groceries").split(separator: ",")
        let alcoholString = view.readFile(folder: "Support Data/", fileName: "Alcohol").split(separator: ",")
        let eatingOutString = view.readFile(folder: "Support Data/", fileName: "EatingOut").split(separator: ",")
        let entertainmentString = view.readFile(folder: "Support Data/", fileName: "Entertainment").split(separator: ",")
        let transportationString = view.readFile(folder: "Support Data/", fileName: "Transportation").split(separator: ",")
        
        necessitiesString.forEach {
            necessitiesExclusions.append(TransactionCategoryExclusion(name: String($0), transactionCategory: .Necessities, itemNumber: itemNumber))
            itemNumber += 1
        }
        financialString.forEach { financialExclusions.append(TransactionCategoryExclusion(name: String($0), transactionCategory: .Financial, itemNumber: itemNumber))
            itemNumber += 1
        }
        groceriesString.forEach { groceriesExclusions.append(TransactionCategoryExclusion(name: String($0), transactionCategory: .Groceries, itemNumber: itemNumber))
            itemNumber += 1
        }
        alcoholString.forEach { alcoholExclusions.append(TransactionCategoryExclusion(name: String($0), transactionCategory: .Alcohol, itemNumber: itemNumber))
            itemNumber += 1
        }
        eatingOutString.forEach { eatingOutExclusions.append(TransactionCategoryExclusion(name: String($0), transactionCategory: .EatingOut, itemNumber: itemNumber))
            itemNumber += 1
        }
        entertainmentString.forEach { entertainmentExclusions.append(TransactionCategoryExclusion(name: String($0), transactionCategory: .Entertainment, itemNumber: itemNumber))
            itemNumber += 1
        }
        transportationString.forEach { transportationExclusions.append(TransactionCategoryExclusion(name: String($0), transactionCategory: .Transportation, itemNumber: itemNumber))
            itemNumber += 1
        }
        
        allLists = [necessitiesExclusions, financialExclusions, groceriesExclusions, alcoholExclusions, eatingOutExclusions, entertainmentExclusions, transportationExclusions]
    }
    
    func categorize(by description: String) -> String? {
        
        var found: String? = nil
        
        alcoholExclusions.forEach { if description.contains($0.name) { found = "Alcohol"} }
        necessitiesExclusions.forEach { if description.contains($0.name) { found = "Necessities"} }
        eatingOutExclusions.forEach { if description.contains($0.name) { found = "Eating Out"} }
        entertainmentExclusions.forEach { if description.contains($0.name) { found = "Entertainment"} }
        groceriesExclusions.forEach { if description.contains($0.name) { found = "Groceries"} }
        transportationExclusions.forEach { if description.contains($0.name) { found = "Transportation"} }
        financialExclusions.forEach { if description.contains($0.name) { found = "Financial"} }
        
        return found
    }
    
    func addExclusion(description: String, category: String) {
    
        if category == "Alcohol" {
            alcoholExclusions.append(TransactionCategoryExclusion(name: description, transactionCategory: .Alcohol, itemNumber: itemNumber + 1))
        } else if category == "EatingOut" {
            eatingOutExclusions.append(TransactionCategoryExclusion(name: description, transactionCategory: .EatingOut, itemNumber: itemNumber + 1))
        } else if category == "Entertainment" {
            entertainmentExclusions.append(TransactionCategoryExclusion(name: description, transactionCategory: .Entertainment, itemNumber: itemNumber + 1))
        } else if category == "Financial" {
            financialExclusions.append(TransactionCategoryExclusion(name: description, transactionCategory: .Financial, itemNumber: itemNumber + 1))
        } else if category == "Groceries" {
            groceriesExclusions.append(TransactionCategoryExclusion(name: description, transactionCategory: .Groceries, itemNumber: itemNumber + 1))
        } else if category == "Necessities" {
            necessitiesExclusions.append(TransactionCategoryExclusion(name: description, transactionCategory: .Necessities, itemNumber: itemNumber + 1))
        } else {
            transportationExclusions.append(TransactionCategoryExclusion(name: description, transactionCategory: .Transportation, itemNumber: itemNumber + 1))
        }
        
        writeCategories()
    }
    
    func count() -> Int {
        
        return necessitiesExclusions.count + financialExclusions.count + groceriesExclusions.count + alcoholExclusions.count + eatingOutExclusions.count + entertainmentExclusions.count + transportationExclusions.count
    }
    
    func getItemByNumber(number: Int) -> TransactionCategoryExclusion? {
        
        for list in allLists {
            for exclusion in list {
                if exclusion.itemNumber == number {
                    return exclusion
                }
            }
        }
        
        return nil
    }
}
