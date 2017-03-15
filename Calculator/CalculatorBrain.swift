//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Patrick Wiseman on 2/28/17.
//  Copyright © 2017 Patrick Wiseman. All rights reserved.
//
//Use private for things you think are internal implementations

import Foundation

//Structs do not live in the heap (reference type), passed around by copying
struct CalculatorBrain {
    
    var accumulator: Double?
    var description: String?
    var pendingDescription: String?
    var accumulatorGeneratedNumber = false
    var finishedTypingNumber = false
    
    private enum Operation {
        case constant(Double)
        //Make the associated value a function
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "sin" : Operation.unaryOperation(sin),
        "tan" : Operation.unaryOperation(tan),
        "±" : Operation.unaryOperation({ -$0 }),
        "×" : Operation.binaryOperation({ $0 * $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "−" : Operation.binaryOperation({ $0 - $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "=" : Operation.equals,
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            //value is the associated value with the enum type
            case .constant(let value):
                self.deleteDataForFreshOperationSet()
                accumulator = value
                accumulatorGeneratedNumber = false
                self.setDescriptionForConstant(WithConstant: symbol)
            case .unaryOperation(let function):
                if accumulator != nil {
                    self.setDescriptionForUnaryOperation(withAccumulatorValue: accumulator!, operationSymbol: symbol)
                    accumulator = function(accumulator!)
                    if pendingBinaryOperation != nil {
                        if pendingDescription == nil {
                            pendingBinaryOperation?.firstOperand = accumulator!
                        }
                    }
                }
            case .binaryOperation(let function):
                if finishedTypingNumber == true {
                    let _accumulator = accumulator!
                    if(pendingDescription == nil){
                        setDescription(withAccumulatorValue: _accumulator, operationSymbol: symbol)
                    } else {
                        setDescriptionWithPendingValue(WithOperationSymbol: symbol)
                    }
                    performPendingBinaryOperation()
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                } else {
                    if pendingBinaryOperation != nil {
                        pendingBinaryOperation?.function = function
                        changeDescriptionActiveOperator(ToOperator: symbol)
                    }
                }
            case .equals:
                if finishedTypingNumber == true {
                    if(pendingDescription == nil){
                        setDescription(withAccumulatorValue: accumulator!, operationSymbol: symbol)
                    } else {
                        setDescriptionWithPendingValue(WithOperationSymbol: symbol)
                    }
                    performPendingBinaryOperation()
                } else {
                    if pendingBinaryOperation != nil {
                        changeDescriptionActiveOperator(ToOperator: symbol)
                    }
                }
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        //? if it is not set it will ignore this line
        if pendingBinaryOperation != nil && accumulator != nil {
           accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            accumulatorGeneratedNumber = true
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        var function: (Double, Double) -> Double
        var firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var isPartialResult: Bool {
        get {
            if pendingBinaryOperation != nil && accumulator != nil {
                return true
            } else {
                return false
            }
        }
    }
    
    mutating func deleteDataForFreshOperationSet() {
        if !isPartialResult {
            description = nil
            pendingDescription = nil
        }
    }
    
    mutating func setDescription(withAccumulatorValue accumulatorValue: Double, operationSymbol: String) {
        var accumulatorString = String(accumulatorValue)
        if description != nil {
            let lastChar = description![description!.index(before: description!.endIndex)]
            if lastChar == "=" {
                accumulatorString = ""
                description!.remove(at: description!.index(before: description!.endIndex))
            }
            description = description!+accumulatorString+operationSymbol
        } else {
            description = accumulatorString+operationSymbol
        }
        print(description!)
    }
    
    mutating func changeDescriptionActiveOperator(ToOperator operationSymbol: String) {
        if description != nil {
            description!.remove(at: description!.index(before: description!.endIndex))
            description!.append(operationSymbol)
            print(description!)
        }
    }
    
    mutating func setDescriptionForConstant(WithConstant constant: String) {
        pendingDescription = constant
    }
    
    mutating func setDescriptionForUnaryOperation(withAccumulatorValue accumulatorValue: Double, operationSymbol: String) {
        let accumulatorString = String(accumulatorValue)
        if accumulatorGeneratedNumber == true {
            if description != nil {
                let lastChar = description![description!.index(before: description!.endIndex)]
                description!.remove(at: description!.index(before: description!.endIndex))
                description = "\(operationSymbol)(\(description!))"
                description = description! + String(lastChar)
            }
        } else {
            if pendingDescription != nil {
                pendingDescription = "\(operationSymbol)(\(pendingDescription!))"
            } else {
                pendingDescription = "\(operationSymbol)(\(accumulatorString))"
            }
        }
    }
    
    mutating func setDescriptionWithPendingValue(WithOperationSymbol operationSymbol: String) {
        if description != nil && pendingDescription != nil {
            description = description!+pendingDescription!+operationSymbol
        } else if pendingDescription != nil {
            description = pendingDescription! + operationSymbol
        }
        print(description!)
        pendingDescription = nil
    }
    
    mutating func clearCalculator() {
        accumulator = nil
        description = nil
        pendingBinaryOperation = nil
    }
}
