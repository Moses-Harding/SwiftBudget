//
//  Transaction.swift
//  SwiftBudget
//
//  Created by Moses Harding on 10/27/20.
//

import Foundation

class Transaction {
    
    var account: String
    var category: String
    var date: String
    var amount: Float
    var description: String
    
    init(_ infoString: String) {
        
        let splitString = infoString.replacingOccurrences(of: ",", with: "").split(separator: "}")
        var stringList = [String]()
        splitString.forEach {
            let split = $0.split(separator: "{")
            if split.count > 1 {
                stringList.append(String(split[1]))
            } else {
                stringList.append("NONE")
            }
        }

        self.account = stringList[0]
        self.date = stringList[1]
        self.amount = Float(stringList[2]) ?? 0.0
        self.category = stringList[3]
        self.description = stringList[4]
        
        setCategory()
    }
    
    func setCategory() {
        
        let alcoholList = ["Alcohol & Bars"]
        let financialList = ["Bank Transactions", "Cash & ATM", "Charity", "Gift", "Income", "Interest Income", "Investments", "Mortgage & Rent", "Student Loan"]
        let necessityList = ["Business Services", "Clothing", "Furnishings", "Gym", "Pharmacy", "Shopping"]
        let eatingOutList = ["Coffee Shops", "Fast Food", "Food & Dining", "Restaurants"]
        let entertainmentList = ["Electronics & Software", "Entertainment", "Newspapers & Magazines", "Television"]
        let groceryList = ["Groceries"]
        let transportationList = ["Public Transportation", "Rental Car & Taxi"]
        
        //let filter = FilterData()
        
        if self.account == "VENMO" {
            self.category = "Venmo"
        } else if alcoholList.contains(self.category) {
            self.category = "Alcohol"
        } else if financialList.contains(self.category) {
            self.category = "Financial"
        } else if necessityList.contains(self.category) {
            self.category = "Necessities"
        } else if eatingOutList.contains(self.category) {
            self.category = "Eating Out"
        } else if entertainmentList.contains(self.category) {
            self.category = "Entertainment"
        } else if  groceryList.contains(self.category) {
            self.category = "Groceries"
        } else if transportationList.contains(self.category) {
            self.category = "Transportation"
        } else {
            self.category = "Other"
        }
    }
}

extension Transaction: Equatable {
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return (lhs.amount == rhs.amount) && lhs.account == rhs.account && lhs.date == rhs.date && lhs.description == rhs.description
    }
}
