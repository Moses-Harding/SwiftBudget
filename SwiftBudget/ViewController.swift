//
//  ViewController.swift
//  SwiftBudget
//
//  Created by Moses Harding on 10/27/20.
//

import Cocoa
import PythonKit

class ViewController: NSViewController {
    
    @IBOutlet weak var DatePicker: NSPopUpButton!
    @IBOutlet weak var StartButton: NSButton!
    @IBOutlet weak var RefreshData: NSButton!
    
    //Add Transaction Categories
    @IBOutlet weak var CategorySelectionDropdown: NSPopUpButton!
    @IBOutlet weak var TransactionCategoryEntry: NSTextField!
    @IBOutlet weak var SaveButton: NSButton!
    @IBOutlet weak var ShowTransactionCategoryEntry: NSImageView!
    
    //Background
    @IBOutlet weak var ImageView: NSImageView!
    @IBOutlet weak var Amount: NSTextField!
    
    //Transactions
    @IBOutlet weak var TransactionTable: NSTableView!

    var startDay = Day()
    var endDay = Day()
    
    var fullDayList = [Day]()
    
    var transactionString = ""
    
    //Directory
    var baseDirectory = "/Users/mosesharding/Library/Mobile Documents/com~apple~CloudDocs/Finance/"
    
    var transactionContainer: TransactionContainer?
    
    //Sorting
    var sortOrder = TransactionOrder.Date
    var sortAscending = true
    
    //Exclusions
    var transactionCategoryExclusions: TransactionCategoryContainer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ImageView.layer?.zPosition = -1
        Amount.stringValue = ""
        
        
        setUpCategories()
        
        setUpDates()
        setUpTableview()
        
    }
    
    // MARK: Tableview Functions
    
    func setUpTableview() {
        TransactionTable.delegate = self
        TransactionTable.dataSource = self
        TransactionTable.target = self
        
        let descriptorDate = NSSortDescriptor(key: TransactionOrder.Date.rawValue, ascending: true)
        let descriptorDescription = NSSortDescriptor(key: TransactionOrder.Description.rawValue, ascending: true)
        let descriptorAmount = NSSortDescriptor(key: TransactionOrder.Amount.rawValue, ascending: true)
        let descriptorCategory = NSSortDescriptor(key: TransactionOrder.Category.rawValue, ascending: true)
        let descriptorAccount = NSSortDescriptor(key: TransactionOrder.Account.rawValue, ascending: true)
        
        TransactionTable.tableColumns[0].sortDescriptorPrototype = descriptorDate
        TransactionTable.tableColumns[1].sortDescriptorPrototype = descriptorDescription
        TransactionTable.tableColumns[2].sortDescriptorPrototype = descriptorAmount
        TransactionTable.tableColumns[3].sortDescriptorPrototype = descriptorCategory
        TransactionTable.tableColumns[4].sortDescriptorPrototype = descriptorAccount
    }
    
    func reloadTransactionList() {
        transactionContainer?.contentsOrderedBy(sortOrder, ascending: sortAscending)
        TransactionTable.beginUpdates()
        TransactionTable.reloadData()
        TransactionTable.endUpdates()
    }
    
    
    // MARK: Dates
    
    func getDateList() -> [Day] {
        let today = Day()
        
        var year = today.year - 1
        var month = 1
        var dayList = [Day]()
        
        for _ in 0 ... 1 {
            for m in 0 ..< 12 {
                if m == 0 { month = 1 }
                
                var dayNumber = 15
                var midDate = Day(day: dayNumber, month: month, year: year)
                
                if midDate.dayOfWeek == 1 {
                    midDate = Day(day: dayNumber - 2, month: month, year: year)
                } else if midDate.dayOfWeek == 7 {
                    midDate = Day(day: dayNumber - 1, month: month, year: year)
                }
                
                dayNumber = midDate.lastDayOfMonth()
                var endDate = Day(day: dayNumber, month: month, year: year)
                
                if endDate.dayOfWeek == 1 {
                    endDate = Day(day: dayNumber - 2, month: month, year: year)
                } else if endDate.dayOfWeek == 7 {
                    endDate = Day(day: dayNumber - 1, month: month, year: year)
                }
                
                dayList.append(midDate)
                dayList.append(endDate)
                
                month += 1
            }
            year += 1
        }
        return dayList
    }
    
    func setUpDates() {
        var longList = getDateList()
        fullDayList = longList
        
        longList.reverse()
        guard let firstBelow = longList.firstIndex( where: { $0 <= startDay }) else { fatalError("Current date not found for list") }
        
        let shortList = longList[firstBelow ... (firstBelow + 6)]
        DatePicker.removeAllItems()
        
        shortList.forEach { DatePicker.addItem(withTitle: $0.description)}
    }
    
    // MARK: Transactions
    
    func getTransactions() {
        
        transactionString = readTransactionsCSV()
        
        saveTransactions()
    }
    
    func getTransactionsURL() -> URL? {

        if #available(OSX 11.0, *) {
            let manager = FileManager()
            
            var mostRecentURL: URL?
            var mostRecentDate: Date?
            
            guard let downloads = try? manager.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false), let downloadsContents = try? manager.contentsOfDirectory(at: downloads, includingPropertiesForKeys: [.addedToDirectoryDateKey, .contentTypeKey, .localizedNameKey], options: .skipsHiddenFiles) else {
                fatalError("No downloads")
            }
            for item in downloadsContents {
                guard let keys = try? item.resourceValues(forKeys: [.localizedNameKey, .addedToDirectoryDateKey, .typeIdentifierKey]), let name = keys.localizedName, let date = keys.addedToDirectoryDate, let contentType = keys.typeIdentifier else {
                    break
                }
                
                if name.contains("transactions") && contentType == kUTTypeCommaSeparatedText as String {
                    
                    if let currentDate = mostRecentDate {
                        if currentDate < date {
                            mostRecentDate = date
                            mostRecentURL = item
                        }
                    } else {
                        mostRecentDate = date
                        mostRecentURL = item
                    }
                }
            }
            
            for item in downloadsContents {
                guard let keys = try? item.resourceValues(forKeys: [.localizedNameKey, .addedToDirectoryDateKey, .typeIdentifierKey]), let name = keys.localizedName, let contentType = keys.typeIdentifier else {
                    break
                }
                
                if name.contains("transactions") && contentType == kUTTypeCommaSeparatedText as String && item != mostRecentURL {
                    try? manager.removeItem(at: item)
                }
            }
            
            return mostRecentURL
        } else {
            return nil
        }
        
    }
    
    func readTransactionsCSV() -> String {
        
        var contentString = ""
        do {
            
            if let url = getTransactionsURL() {
                contentString = try String(contentsOf: url, encoding: .utf8)
            }
            
        } catch {
            print("no data fouhnd")
        }
        
        let transactionList = contentString.split(separator: "\n")
        
        var mintTransactions = ""
        
        for i in 0 ..< transactionList.count {
            if i > 0 {
                //print(i)
                let transactionRow = transactionList[i]
                let transactionList = transactionRow.components(separatedBy: "\",\"")
                var transaction = [String]()
                
                transactionList.forEach {
                    let replaced = $0.replacingOccurrences(of: "\"", with: "")
                    
                    transaction.append(replaced)
                }
                
                //Date
                let unformattedDate = String(transaction[0]).replacingOccurrences(of: "\"", with: "")
                let splitDate = unformattedDate.split(separator: "/")
                let date = splitDate[2] + "-" + splitDate[0] + "-" + splitDate[1]
                
                //Name
                let name = String(transaction[2]).replacingOccurrences(of: ":", with: "")
                
                //Category
                let category = String(transaction[5]).replacingOccurrences(of: ":", with: "")
                
                //Amount
                var amountString = ""
                if var amount = Float(transaction[3]) {
                    if transaction[4] == "credit" {
                        amount *= -1
                    }
                    amountString = String(amount)
                }

                mintTransactions += "|financialInstitution{" + String(transaction[6]) + "}date{" + date + "}amount{" + amountString + "}category{" + category + "}name{" + name
            }
        }
        
        return mintTransactions
    }
    
    func readGoogleCSV()-> String {
        
        var contentString = ""
        do {
            
            
            let path = "/Users/mosesharding/Downloads/Credit Card Expenses - 2020.csv"
            
            let url = URL(fileURLWithPath: path)
            
            contentString = try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("no data fouhnd")
        }
        
        let transactionList = contentString.split(separator: "\r\n")

        
        var googleTransactions = ""
        
        for i in 0 ..< transactionList.count {
            if i > 0 {
                let transactionRow = transactionList[i]
                let transactionList = transactionRow.split(separator: ",")
                var transaction = [String]()
                
                
                transactionList.forEach { transaction.append($0.replacingOccurrences(of: "\"", with: "")) }
                
                if transactionList.count > 0 {
                    
                    //Date
                    let unformattedDate = String(transaction[0]).replacingOccurrences(of: "\"", with: "")
                    let splitDate = unformattedDate.split(separator: "/")
                    let date = splitDate[2] + "-" + splitDate[0] + "-" + splitDate[1]
                    
                    //Name
                    let name = transaction[1]
                    
                    //Amount
                    var splitAmount = ""
                    
                    if var amount = Float(transaction[2]) {
                    
                        if transaction[3] == "TRUE" {
                            splitAmount = String(amount / 2)
                        } else if transaction[4] == "TRUE" {
                            splitAmount = String(amount)
                        } else {
                            splitAmount = "0"
                        }
                    }
                    googleTransactions += "|financialInstitution{" + "CAPITAL ONE" + "}date{" + date + "}amount{" + splitAmount + "}category{" + "Other" + "}name{" + name
                }
            }
        }

        return googleTransactions
    }
    
    func formatTransactions() {
        transactionContainer = TransactionContainer(transactionString, startDay: startDay, endDay: endDay, view: self)
        Amount.stringValue = String(transactionContainer!.total.rounded(toPlaces: 2))
        makeSheet()
    }
    
    func retrieveSavedTransactions() {
        
        transactionString = readFile(folder: "Statements/", fileName: "transactionData.txt")
    }
    
    func saveTransactions() {
        do {
            let fileName = "transactionData.txt"
            
            let path = "/Users/mosesharding/Library/Mobile Documents/com~apple~CloudDocs/Finance/Statements/"
            
            let url = URL(fileURLWithPath: path)
            
            let fileURL = url.appendingPathComponent(fileName)
            
            try transactionString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("error creating file")
        }
    }
    
    func makeSheet() {
        let fileName = startDay.formatted
        let folderPath = "/Users/mosesharding/Library/Mobile Documents/com~apple~CloudDocs/Finance/Statements/" + String(startDay.year) + "/" + String(startDay.formatted)
        
        let sys = Python.import("sys")
        sys.path.append("/Users/mosesharding/Library/Mobile Documents/com~apple~CloudDocs/Finance/SwiftBudget/Python/") // path to your Python file's directory.
        let makeSheet = Python.import("makeSheet")
        makeSheet.createWorksheet(folderPath, fileName, "WHAT IS THIS?")
    }
    
    // MARK: Reading and writing
    
    func writeToFile(folder: String, fileName: String, content: String) {
        do {
            let baseFolderPath = "/Users/mosesharding/Library/Mobile Documents/com~apple~CloudDocs/Finance/" + folder
            let sys = Python.import("sys")
            sys.path.append(baseFolderPath) // path to your Python file's directory.
            let url = URL(fileURLWithPath: baseFolderPath)
            
            let fileURL = url.appendingPathComponent(fileName)
            
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("error creating file")
        }
    }
    
    func readFile(folder: String, fileName: String) -> String {
        
        var contentString = ""
        do {
            
            let path = "/Users/mosesharding/Library/Mobile Documents/com~apple~CloudDocs/Finance/" + folder
            
            let url = URL(fileURLWithPath: path)
            
            let fileURL = url.appendingPathComponent(fileName)
            
            contentString = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            print("no data fouhnd")
        }
        
        return contentString
    }
    
    // MARK: Categories
    
    
    func setUpCategories() {
        
        transactionCategoryExclusions = TransactionCategoryContainer(view: self)
        
        CategorySelectionDropdown.removeAllItems()
        
        TransactionCategory.allCases.forEach { CategorySelectionDropdown.addItem(withTitle: $0.rawValue) }
    }
    
    // MARK: Actions
    
    @IBAction func start(_ sender: Any) {
        
        if let selected = DatePicker.titleOfSelectedItem {
            startDay = Day(from: selected)
        }
        
        var index = (fullDayList.firstIndex { $0 == startDay }! + 1)
        if index == fullDayList.count {
            index = fullDayList.count - 1
        }
        
        endDay = fullDayList[index]
        
        if RefreshData.state == .on {
            getTransactions()
        } else {
            retrieveSavedTransactions()
        }
        
        formatTransactions()
        
        TransactionTable.reloadData()
    }
    
    @IBAction func setDay(_ sender: Any) {
        
        if let selected = DatePicker.titleOfSelectedItem {
            startDay = Day(from: selected)
        }
    }
    
    @IBAction func showTransactionCategoryEntry(_ sender: Any) {
        CategorySelectionDropdown.isHidden = !CategorySelectionDropdown.isHidden
        TransactionCategoryEntry.isHidden = !TransactionCategoryEntry.isHidden
        SaveButton.isHidden = !SaveButton.isHidden
    }
    
    @IBAction func saveTransactionCategories(_ sender: Any) {
        
        let newValue = TransactionCategoryEntry.stringValue
        let cat = CategorySelectionDropdown.titleOfSelectedItem
        
        transactionCategoryExclusions.addExclusion(description: newValue, category: cat!)
        
        TransactionCategoryEntry.stringValue = ""
        
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return transactionContainer?.transactions.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }
        
        if let order = TransactionOrder(rawValue: sortDescriptor.key!) {
            sortOrder = order
            sortAscending = sortDescriptor.ascending
            reloadTransactionList()
        }
    }
    
}

extension ViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let DateCell = "DateCellID"
        static let DescriptionCell = "DescriptionCellID"
        static let AmountCell = "AmountCellID"
        static let AccountCell = "AccountCellID"
        static let CategoryCell = "CategoryCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        var cellColor = ""
        
        guard let item = transactionContainer?.transactions[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            let splitDate = item.date.split(separator: "-")
            text = splitDate[1] + "/" + splitDate[2]
            cellIdentifier = CellIdentifiers.DateCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.description
            cellIdentifier = CellIdentifiers.DescriptionCell
        } else if tableColumn == tableView.tableColumns[2] {
            text = String(item.amount)
            cellIdentifier = CellIdentifiers.AmountCell
        } else if tableColumn == tableView.tableColumns[3] {
            text = item.category
            cellIdentifier = CellIdentifiers.CategoryCell
        } else if tableColumn == tableView.tableColumns[4] {
            text = item.account
            cellIdentifier = CellIdentifiers.AccountCell
        }
        
        switch item.account {
        case "Chase Bank":
            cellColor = "284B63"
        case "Citibank Credit Card":
            cellColor = "3C6E71"
        case "Venmo":
            cellColor = "709176"
        case "VISIONS Federal Credit Union":
            cellColor = "6E0E0C"
        case "PayPal":
            cellColor = "669D31"
        case "CapitalOne":
            cellColor = "B56576"
        default:
            cellColor = "6E0E0C"
        }
        
        if let rowView = TransactionTable.rowView(atRow: row, makeIfNecessary: false) {
            rowView.backgroundColor = hexToNSColor(from: cellColor)
        }
        
        if let cell = TransactionTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
