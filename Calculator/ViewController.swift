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
    
    @IBAction func touchDigit(_ sender: UIButton) {
        //Always have swift infer types
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display!.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
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
    
    private var brain = CalculatorBrain()
    
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

