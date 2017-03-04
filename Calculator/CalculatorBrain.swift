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
    var didChainOperation = false
    
    private enum Operation {
        case constant(Double)
        //Make the associated value a function
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi), //These should function more like numbers than operations
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
                accumulator = value
                setDescription(symbol, replaceValueForUnaryOperation: nil)
                if didChainOperation == true {
                    didChainOperation = false
                }
            case .unaryOperation(let function):
                if accumulator != nil {
                    let descriptionString = accumulator!.clean
                    setDescription(symbol+"("+descriptionString+")", replaceValueForUnaryOperation: descriptionString)
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                if(isPartialResult){
                    setDescription(symbol, replaceValueForUnaryOperation: nil)
                    performPendingBinaryOperationWithChain(symbolFunction: function)
                } else {
                    if accumulator != nil {
                        if description == nil {
                            if let _accumulator = accumulator {
                                setDescription(_accumulator.clean, replaceValueForUnaryOperation: nil)
                            }
                        }
                        setDescription(symbol, replaceValueForUnaryOperation: nil)
                        pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                        accumulator = nil
                    } else {
                        if pendingBinaryOperation != nil {
                            setDescription(symbol, replaceValueForUnaryOperation: nil)
                            pendingBinaryOperation?.function = function
                        }
                    }
                }
            case .equals:
                setDescription(symbol, replaceValueForUnaryOperation: nil)
                clearDescription()
                performPendingBinaryOperation()
                pendingBinaryOperation = nil
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        //? if it is not set it will ignore this line
        if pendingBinaryOperation != nil && accumulator != nil && didChainOperation == false {
           accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private mutating func performPendingBinaryOperationWithChain(symbolFunction:@escaping (Double, Double) -> Double) {
        performPendingBinaryOperation()
        if accumulator != nil {
            pendingBinaryOperation = PendingBinaryOperation(function: symbolFunction, firstOperand: accumulator!)
            didChainOperation = true
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
    
    mutating func setDescription(_ value: String, replaceValueForUnaryOperation unaryReplaceString: String?) {
        if let unwrappedDescription = description {
            var workingDescription = unwrappedDescription
            //Unary Operation was Used Replace the operand the unary operation was used on 
            //and clear description if no operations are in the pipeline cos(x)
            if let _unaryReplaceString = unaryReplaceString {
                let index = workingDescription.range(of: _unaryReplaceString, options: .backwards)?.lowerBound
                if isLastCharacterWrapped(FromOriginalString: workingDescription) {
                   workingDescription = ""
                } else {
                    if let _index = index {
                        workingDescription = workingDescription.substring(to: _index)
                    } else {
                        clearDescription()
                    }
                }
            }
            //If the user taps + and then taps - just switch them around dont let the operations stack up
            if isLastCharacterASymbol(FromOriginalString: unwrappedDescription) {
                if isLastCharacterASymbol(FromOriginalString: value){
                    workingDescription = workingDescription.substring(to: workingDescription.index(before: workingDescription.endIndex))
                }
            }
            description = workingDescription + "\(value)"
            
        } else {
            description = value
        }
        if let _description = description {
            let descriptionInfo = ["description": _description] as [String: String]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "calculationPerformed"),
                                            object: nil,
                                            userInfo: descriptionInfo)
        }
    }
    
    mutating func clearDescription() {
        description = nil
    }
    
    func isLastCharacterASymbol(FromOriginalString string: String) -> Bool {
        let lastChar = string.characters.last
        for symbol in operations {
            if symbol.key == String(describing: lastChar!)
                && symbol.key != "π"
                && symbol.key != "e"{
                return true
            }
        }
        return false
    }
    func isLastCharacterWrapped(FromOriginalString string: String) -> Bool {
        let lastChar = string.characters.last
        if let _lastChar = lastChar {
            print(_lastChar)
            if _lastChar == ")" {
                return true
            }
        }
        return false
    }
    
    mutating func clearCalculator() {
        accumulator = nil
        pendingBinaryOperation = nil
        didChainOperation = false
        clearDescription()
    }
}
