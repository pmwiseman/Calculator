//
//  ViewController.swift
//  Calculator
//
//  Created by Patrick Wiseman on 2/28/17.
//  Copyright © 2017 Patrick Wiseman. All rights reserved.
//
//Extra credit to only allow a certain number of digits 
//in the display

//To Do
//Constants


import UIKit

extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var calculationsPerformed: UILabel!
    var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    
    override func viewDidLoad() {
        brain.accumulator = 0
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeDescriptionForPerformedCalculationPerformed(notification:)),
                                               name: NSNotification.Name(rawValue: "calculationPerformed"),
                                               object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //Display
        self.display.layer.borderColor = UIColor.gray.cgColor
        self.display.layer.borderWidth = 1.0
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        //Always have swift infer types
        brain.deleteDataForFreshOperationSet()
//        if !brain.isPartialResult {
//            brain.description = nil
//            brain.pendingDescription = nil
//        }
        var digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            guard textCurrentlyInDisplay.contains(".") && digit == "." else {
                display!.text = textCurrentlyInDisplay + digit
                return
            }
        } else {
            if(digit == "."){
                digit = "0" + digit
            }
            display.text = digit
            userIsInTheMiddleOfTyping = true
            brain.accumulatorGeneratedNumber = false
            brain.finishedTypingNumber = false
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
            
            display.text = newValue.clean
        }
    }
    
    func changeDescriptionForPerformedCalculationPerformed(notification: Notification) {
        guard let descriptionInfo = notification.userInfo else { return }
        calculationsPerformed.text = descriptionInfo["description"] as! String?
    }
    
    @IBAction func clearCalculator(_ sender: UIButton) {
        displayValue = 0
        userIsInTheMiddleOfTyping = false
        brain.finishedTypingNumber = true
        calculationsPerformed.text = "0"
        brain.clearCalculator()
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            brain.finishedTypingNumber = true
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
    }
}

