//
//  ViewController.swift
//  Calculator
//
//  Created by Patrick Wiseman on 2/28/17.
//  Copyright © 2017 Patrick Wiseman. All rights reserved.
//
//Extra credit to only allow a certain number of digits 
//in the display

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    
    override func viewDidLoad() {
        brain.accumulator = 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //Display
        self.display.layer.borderColor = UIColor.gray.cgColor
        self.display.layer.borderWidth = 1.0
    }
    
    private enum Constant {
        case constant(Double)
    }
    
    private var constants: Dictionary<String, Constant> = [
        "π" : Constant.constant(Double.pi),
        "e" : Constant.constant(M_E),
        ]
    
    @IBAction func touchDigit(_ sender: UIButton) {
        //Always have swift infer types
        var digit = sender.currentTitle!
        if let constant = constants[sender.currentTitle!] {
            switch constant {
            case .constant(let value):
                digit = String(value)
            }
        }
        if brain.didChainOperation == true {
            brain.didChainOperation = false
        }
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            guard textCurrentlyInDisplay.contains(".") && digit == "." else {
                display!.text = textCurrentlyInDisplay + digit
                brain.setDescription(digit)
                return
            }
        } else {
            if(digit == "."){
                digit = "0" + digit
            }
            display.text = digit
            brain.setDescription(digit)
            userIsInTheMiddleOfTyping = true
        }
    }
    
    //Computed Property
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            //newValue is the value on the right side of the equals
            //when someone says this var = something
            display.text = String(newValue)
        }
    }
    
    @IBAction func clearCalculator(_ sender: UIButton) {
        displayValue = 0
        userIsInTheMiddleOfTyping = false
        brain.clearCalculator()
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
    }
}

