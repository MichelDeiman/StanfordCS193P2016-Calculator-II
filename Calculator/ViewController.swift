//
//  ViewController.swift
//  Calculator
//
//  Created by Michel Deiman on 11/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
	@IBOutlet private weak var display: UILabel!
	@IBOutlet weak var descriptionDisplay: UILabel!
	
	private var brain = CalculatorBrain()
	
	private var userIsInTheMiddleOfTyping = false {
		didSet {
			useInitialNullValueAsOperand = false
		}
	}
	private var useInitialNullValueAsOperand = true


	@IBAction private func touchDigit(sender: UIButton) {
		let digit = sender.currentTitle!
		if userIsInTheMiddleOfTyping
		{	display.text = display.text! + digit
		} else
		{	display.text = digit
			userIsInTheMiddleOfTyping = true
		}
	}
	
	@IBAction func floatingPoint()
	{	if !userIsInTheMiddleOfTyping {
			display.text = "0."
		} else
		if display.text?.rangeOfString(".") == nil {
			display.text = display.text! + "."
		}
		userIsInTheMiddleOfTyping = true
	}

	private var displayValue: Double? {
		get {
			return Double(display.text!)
		}
		set {
			display.text = numberFormatter.stringFromNumber(newValue ?? 0)
		}
	}

	@IBAction func clearAll()
	{	brain.clear()
		displayValue = brain.result
		useInitialNullValueAsOperand = true
	}
	
	@IBAction func backSpace()
	{	guard userIsInTheMiddleOfTyping else { return }
		if display.text?.characters.count <= 1
		{	displayValue = nil
			userIsInTheMiddleOfTyping = false
			return
		}
		display.text = String(display.text!.characters.dropLast())
	}

	@IBAction private func performOperation(sender: UIButton) {		
		if userIsInTheMiddleOfTyping || useInitialNullValueAsOperand {
			brain.setOperand(displayValue!)
			userIsInTheMiddleOfTyping = false
		}
		let mathematicalSymbol = sender.currentTitle
		brain.performOperation(mathematicalSymbol!)
		displayValue = brain.result
		let postfixDescription = brain.isPartialResult ? "..." : "="
		descriptionDisplay.text = brain.description + postfixDescription
	}
	
	var numberFormatter = NSNumberFormatter()
			
	override func viewDidLoad() {
		super.viewDidLoad()
		numberFormatter.alwaysShowsDecimalSeparator = false
		numberFormatter.maximumFractionDigits = 6
		numberFormatter.minimumFractionDigits = 0
		numberFormatter.minimumIntegerDigits = 1
		brain.numberFormatter = numberFormatter
	}
}

