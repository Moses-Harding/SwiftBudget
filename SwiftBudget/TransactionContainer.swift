//
//  TransactionContainer.swift
//  SwiftBudget
//
//  Created by Moses Harding on 11/8/20.
//

import Foundation

class TransactionContainer {
    
    var transactions = [Transaction]()
    var appleList = [Transaction]()
    var bananaList = [Transaction]()
    var chaseList = [Transaction]()
    var citiList = [Transaction]()
    var citiBankingList = [Transaction]()
    var venmoList = [Transaction]()
    var visionsList = [Transaction]()
    var paypalList = [Transaction]()
    var capitalOneList = [Transaction]()
    var otherList = [Transaction]()
    
    var total: Double = 0
    
    var view: ViewController!
    
    var order: TransactionOrder = .None
    
    init(_ infoString: String, startDay: Day, endDay: Day, view: ViewController) {
        self.view = view
        
        let splitString = infoString.split(separator: "|")
        splitString.forEach {
            let transactionString = String($0)
            let transaction = Transaction(transactionString)
            let date = transaction.date
            
            if let foundCat = self.view.transactionCategoryExclusions.categorize(by: transaction.description) {
                transaction.category = foundCat
            }
            
            if transaction.account == "CAPITAL ONE" {
                transaction.amount /= 2
            }
            
            if passesFilter(transaction: transaction) && (startDay.lessThan(date) || startDay.equalTo(date)) && (endDay.greaterThan(date)) {
                transactions.append(transaction)
            }
        }
        
        for transaction in transactions {
            switch transaction.account {
            case "APPLE":
                appleList.append(transaction)
            case "BANANA REPUBLIC":
                bananaList.append(transaction)
            case "CHASE":
                chaseList.append(transaction)
            case "CITI":
                citiList.append(transaction)
            case "CITI SAVINGS":
                citiBankingList.append(transaction)
            case "CITI CHECKING":
                citiBankingList.append(transaction)
            case "VENMO":
                venmoList.append(transaction)
            case "VISIONS SAVINGS":
                visionsList.append(transaction)
            case "VISIONS CHECKING":
                visionsList.append(transaction)
            case "PAYPAL":
                paypalList.append(transaction)
            case "CAPITAL ONE":
                capitalOneList.append(transaction)
            default:
                otherList.append(transaction)
            }
        }
        
        createCSV(from: appleList, accountName: "APPLE", day: startDay)
        createCSV(from: bananaList, accountName: "BANANA REPUBLIC", day: startDay)
        createCSV(from: chaseList, accountName: "CHASE", day: startDay)
        createCSV(from: citiList, accountName: "CITI", day: startDay)
        createCSV(from: citiBankingList, accountName: "CITI BANKING", day: startDay)
        createCSV(from: venmoList, accountName: "VENMO", day: startDay)
        createCSV(from: visionsList, accountName: "VISIONS", day: startDay)
        createCSV(from: paypalList, accountName: "PAYPAL", day: startDay)
        createCSV(from: capitalOneList, accountName: "CAPITAL ONE", day: startDay)
        createCSV(from: transactions, accountName: "All Transactions", day: startDay)
        createCSV(from: otherList, accountName: "Other", day: startDay)
        
        for transaction in transactions {
            total += Double(transaction.amount)
        }
    }
    
    func passesFilter(transaction: Transaction) -> Bool {
        
        //Apple
        if transaction.account == "APPLE" && transaction.description.contains("Payment Received") {
            return false
        }
        
        //Banana Republic
        if transaction.account.contains("BANANA REPUBLIC") && (transaction.description.contains("THANK YOU") || transaction.description.contains("REFUND CHECK"))  {
            return false
        }
        
        //Barclays
        if transaction.description.contains("Payment Received") && transaction.account.contains("Barclays Card") {
            return false
        }
        
        //Capital One
        if transaction.account == "CAPITAL ONE" && transaction.description.contains("ONLINE PYMT") {
            return false
        }
        
        //Citi checking
        if transaction.account == "CITI CHECKING" && transaction.description.contains("ACH Electronic Credit") && transaction.amount == -100 {
            return false
        }
        
        //Visions
        if transaction.account.contains("VISIONS") && (transaction.description.contains("ACH VENMO") || transaction.description.contains("ACH TRINET") || transaction.description.contains("ACH FEDLOANSERVICING TYPE") ||
            transaction.description.contains("ACH BARCLAYCARD US") ||
            transaction.description.contains("Withdrawal ACH Banana Visa") || transaction.description.contains("Withdrawal ACH CAPITAL ONE") || transaction.description.contains("Transfer From Share") || transaction.description.contains("Transfer To Share") ||
            transaction.amount.rounded(.down) == 2283) {
            return false
        }
        
        //Venmo
        if (transaction.amount.rounded(.up) == -1141 && transaction.account == "Venmo") || transaction.description.contains("Rent") {
            return false
        }
        
        let filterData = view.readFile(folder: "Support Data/", fileName: "filter.txt")
        
        let filterList = filterData.split(separator: ",")
        
        for item in filterList {
            if transaction.description.contains(item) || item.contains(transaction.description) {
                return false
            }
        }
        
        if transaction.account == "VISIONS Federal Credit Union" && (transaction.description == "Capital One" || transaction.description == "Venmo") {
            return false
        }
        
        return true
    }
    
    func createCSV(from transactionList: [Transaction], accountName: String, day: Day) {
        
        var sortedTransactions = transactionList
        sortedTransactions.sort { $0.amount < $1.amount }
        var csvString = ""
        
        
        
        for transaction in sortedTransactions {
            csvString += transaction.date + "," + transaction.description + "," + transaction.category + "," + String(transaction.amount)
            if accountName == "All Transactions" {
                csvString += "," + transaction.account
            }
            csvString += "\n"
        }
        
        let fileManager = FileManager.default
        
        
        
        
        do {
            let fileName = accountName + ".csv"
            
            let path = "/Users/mosesharding/Library/Mobile Documents/com~apple~CloudDocs/Finance/Statements/" + String(day.year) + "/" + String(day.formatted) + "/CSVs/"
            let url = URL(fileURLWithPath: path)
            
            if !fileManager.fileExists(atPath: path) {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: .none)
            }
            
            
            let fileURL = url.appendingPathComponent(fileName)
            
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("error creating file")
        }
    }
    
    func contentsOrderedBy(_ orderedBy: TransactionOrder, ascending: Bool) -> [Transaction] {
        
        self.order = orderedBy
        switch orderedBy {
        case .Account:
            if ascending { transactions.sort {$0.account > $1.account}
            } else {
                transactions.sort {$0.account < $1.account}
            }
        case .Amount:
            if ascending {
                transactions.sort {$0.amount > $1.amount}
            } else {
                transactions.sort {$0.amount < $1.amount}
            }
        case .Category:
            if ascending {
                transactions.sort {$0.category > $1.category}
            } else {
                transactions.sort {$0.category < $1.category}
            }
        case .Date:
            if ascending {
                transactions.sort {$0.date > $1.date}
            } else {
                transactions.sort {$0.date < $1.date}
            }
        default:
            if ascending {
                transactions.sort {$0.description > $1.description}
            } else {
                transactions.sort {$0.description < $1.description}
            }
        }
        return transactions
    }
    
    func sortTransactions<T: Comparable>(lhs: T, rhs: T, ascending: Bool) -> Bool {
        return ascending ? (lhs < rhs) : (lhs > rhs)
    }
}
