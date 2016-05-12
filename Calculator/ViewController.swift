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
	
	private var brain = CalculatorBrain()
	private var userIsInTheMiddleOfTyping = false


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

	private var displayValue: Double {
		get {
			return Double(display.text!)!
		}
		set {
			display.text = String(newValue)
		}
	}
	
	// 𝑥²   ¹∕𝑥  𝑥³

	var savedProgram: CalculatorBrain.PropertyList?
	@IBAction func save()
	{	savedProgram = brain.program
	}
	
	@IBAction func restore()
	{	guard let savedProgram = savedProgram else { return }
		brain.program = savedProgram
		displayValue = brain.result
	}

	@IBAction private func performOperation(sender: UIButton) {
		if userIsInTheMiddleOfTyping {
			brain.setOperand(displayValue)
			userIsInTheMiddleOfTyping = false
		}
		if let mathematicalSymbol = sender.currentTitle {
			brain.performOperation(mathematicalSymbol)
		}
		displayValue = brain.result
	}
}

