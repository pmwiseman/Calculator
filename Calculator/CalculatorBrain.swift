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
                accumulator = value
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                performPendingBinaryOperation()
                pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        //? if it is not set it will ignore this line
        if pendingBinaryOperation != nil && accumulator != nil {
           accumulator = pendingBinaryOperation!.perform(with: accumulator!)
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
    
    mutating func clearCalculator() {
        accumulator = nil
        pendingBinaryOperation = nil
    }
}
