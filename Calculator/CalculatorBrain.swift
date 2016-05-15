//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michel Deiman on 11/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import Foundation
class CalculatorBrain  {
	
	////////////////////////  Private methods and properties

	func setOperand(operand: Double) {
		accumulator = operand
		if pending == nil { internalProgram = [] }
		pending?.secondOperandIsSet = true
		internalProgram.append(operand)
	}
	
	func setOperand(variableName: String) {
		var operandValue = 0.0
		if let operation = operations[variableName] {
			switch operation {
			case .Constant(let value):
				operandValue = value
			case .Variable(let value):
				operandValue = value
			case .Formula(let f):
				operandValue = f()
			default: break
			}
		}
		accumulator = operandValue
		if pending == nil { internalProgram = [] }
		pending?.secondOperandIsSet = true
		internalProgram.append(variableName)
	}
	
	func performOperation(symbol: String) {
		if operations[symbol] == nil {
			variableValues[symbol] = 0.0
		}
		let operation = operations[symbol]!
		switch operation {
		case .Constant, .Variable, .Formula:
			setOperand(symbol)
		default:
			if isPartialResult {
				if pending?.secondOperandIsSet == true {
					executePendingBinaryOperation()
				} else {
					internalProgram.removeLast()
					pending = nil
				}
			}
			switch operation {
			case .UnaryOperation(_, let f):
				accumulator = f(accumulator)
				internalProgram.append(symbol)
			case .BinaryOperation(let f):
				pending = PendingBinaryOperationInfo(binaryFunction: f, firstOperand: accumulator)
				internalProgram.append(symbol)
			default:
				break
			}
		}
	}
	
	func undoLast() {
		guard !internalProgram.isEmpty  else { return }
		internalProgram.removeLast()
		program = internalProgram
	}
	
	var isPartialResult: Bool
	{	return pending != nil
	}

	typealias PropertyList = AnyObject
	var program: PropertyList
	{	get
		{	return internalProgram
		}
		set
		{	pending = nil
			internalProgram = []
			guard let propertyList = newValue as? [AnyObject]
			else { return }
			for property in propertyList
			{	if let operand = property as? Double
				{	setOperand(operand)
				}
				else if let operation = property as? String
				{	performOperation(operation)
				}
			}
		}
	}
	
	var variableValues = [String: Double]() {
		willSet {
			for (symbol,_) in variableValues {
				operations[symbol] = nil
			}
			for (symbol, value) in newValue {
				operations[symbol] = Operation.Variable(value)
			}
			program = internalProgram
		}
	}
	
	var description: String {
		var targetString = String()
		for property in internalProgram
		{	if let operand = property as? Double {
				targetString += numberFormatter?.stringFromNumber(operand) ?? String(operand)
				
			}
			else if let symbol = property as? String
			{	if let operation = operations[symbol]
				{	switch operation {
					case .UnaryOperation(let printOrder, _):
						switch printOrder {
						case .Postfix(let symbol):
							targetString = "(" + targetString + ")" + symbol
						case .Prefix(let symbol):
							targetString = symbol + "(" + targetString + ")"
						}
					case .Equals: break
					default:
						targetString = targetString + symbol
					}
				}
				else {
					targetString = targetString + symbol
				}
			}
		}
		return targetString
	}
	
	func reset() {
		pending = nil
		accumulator = 0.0
		internalProgram = [accumulator]
		variableValues = [:]
	}
	
	var result: Double {
		return accumulator
	}
	var numberFormatter: NSNumberFormatter?
	
	////////////////////////  Private methods and properties
	
	private var accumulator = 0.0
	private var internalProgram : [AnyObject] = [0.0]

	private var operations: [String: Operation] = [
		"×"		: Operation.BinaryOperation(*),
		"÷"		: Operation.BinaryOperation(/),  // { $0 / $1 },
		"+"		: Operation.BinaryOperation(+),
		"−"		: Operation.BinaryOperation { $0 - $1 },
		"√"		: Operation.UnaryOperation(.Prefix("√"), sqrt),
		"¹∕ⅹ"	: Operation.UnaryOperation(.Postfix("⁻¹")) { 1/$0 },
		"x²"	: Operation.UnaryOperation(.Postfix("²")) { $0 * $0 },
		"%"		: Operation.UnaryOperation(.Postfix("%")) { $0 / 100 },
		"sin"	: Operation.UnaryOperation(.Prefix("sin"), sin),
		"cos"	: Operation.UnaryOperation(.Prefix("cos"), cos),
		"tan"	: Operation.UnaryOperation(.Prefix("tan"), tan),
		"±"		: Operation.UnaryOperation(.Postfix("-")) { -$0 },
		"Rand"	: Operation.Formula(drand48),
		"π"		: Operation.Constant(M_PI),
		"e"		: Operation.Constant(M_E),
		"="		: Operation.Equals
	]
	
	private enum Operation //: CustomStringConvertible
	{	case Constant(Double)
		case Variable(Double)
		case Formula(()->Double)
		case UnaryOperation(PrintInfo, Double -> Double)
		case BinaryOperation((Double, Double) -> Double)
		case Equals
		
		enum PrintInfo {
			case Prefix(String)
			case Postfix(String)
		}
	}
	
	private var pending: PendingBinaryOperationInfo?
	
	private struct PendingBinaryOperationInfo {
		var binaryFunction: (Double, Double) -> Double
		var firstOperand: Double
		var secondOperandIsSet: Bool
		
		init(binaryFunction: (Double, Double) -> Double, firstOperand: Double, secondOperandIsSet: Bool = false)
		{	self.binaryFunction = binaryFunction
			self.firstOperand = firstOperand
			self.secondOperandIsSet = secondOperandIsSet
		}
	}

	private func executePendingBinaryOperation()
	{	if let pending = pending {
			accumulator = pending.binaryFunction(pending.firstOperand, accumulator)
			self.pending = nil
		}
	}
}
