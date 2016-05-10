//
//  ViewController.swift
//  Calculator
//
//  Created by Michel Deiman on 07/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
	@IBOutlet weak var display: UILabel!
	@IBOutlet weak var history: UILabel!
	
	var userIsInTheMiddleOfTypingANumber = false
	
	var brain = CalculatorBrain()
	
	@IBAction func appendDigit(sender: UIButton)
	{	let digit = sender.currentTitle!
		if userIsInTheMiddleOfTypingANumber
		{	display.text = display.text! + digit
		} else
		{	display.text = digit
			userIsInTheMiddleOfTypingANumber = true
		}
	}
	
	@IBAction func backSpace()
	{	guard userIsInTheMiddleOfTypingANumber else { return }
		if display.text?.characters.count <= 1
		{	displayValue = nil
			userIsInTheMiddleOfTypingANumber = false
			return
		}
		display.text = String(display.text!.characters.dropLast())
	}
	
	@IBAction func clearAll()
	{	displayValue = nil
		userIsInTheMiddleOfTypingANumber = false
		brain.clearStack()
		history.text = "history"
	}
	
	@IBAction func floatingPoint()
	{	if display.text?.rangeOfString(".") == nil
		{	display.text = display.text! + "."
			userIsInTheMiddleOfTypingANumber = true
		}
	}
	
	@IBAction func setSign(sender: UIButton)
	{	if userIsInTheMiddleOfTypingANumber
		{	displayValue = -1 * displayValue!
		} else
		{	operate(sender)
		}
	}
	
	
	@IBAction func operate(sender: UIButton)
	{
		if userIsInTheMiddleOfTypingANumber
		{	enter()
		}
		let operation = sender.currentTitle!
		if let result = brain.performOperation(operation)
		{	history.text = history.text! + "[\(operation)][=]"
			displayValue = result
			enter()
		}
		
	}

	var displayValue: Double?
	{	get
		{	return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
		}
		set
		{	display.text = newValue == nil ? "0" : "\(newValue!)"
		}
	}
	
	@IBAction func enter()
	{	userIsInTheMiddleOfTypingANumber = false
		displayValue = brain.pushOperand(displayValue!)
		history.text = history.text! + "[\(displayValue!)]"
	}
	
}

