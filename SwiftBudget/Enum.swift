//
//  Enum.swift
//  SwiftBudget
//
//  Created by Moses Harding on 11/3/20.
//

import Foundation

enum TransactionOrder: String {
    case Date, Account, Description, Amount, Category, None
}

enum TransactionCategory: String, CaseIterable {
    case Alcohol, EatingOut, Entertainment, Financial, Groceries, Necessities, Transportation
}
