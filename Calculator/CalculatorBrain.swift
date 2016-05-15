//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michel Deiman on 11/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import Foundation
class CalculatorBrain  {

	func undoLast() {
		guard !internalProgram.isEmpty  else { return }
		internalProgram.removeLast()
		program = internalProgram
	}
	
	func setOperand(operand: Double) {
		accumulator = operand
		if pending == nil { clear() }
		else { executePendingBinaryOperation() }
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
			default: break
			}
		}
		if pending == nil { clear() }
		accumulator = operandValue
		internalProgram.append(variableName)
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
	
	func performOperation(symbol: String) {
		if let operation = operations[symbol]
		{	switch operation {
			case .Constant, .Variable:
				setOperand(symbol)
			default:
				if pending != nil { undoLast() }
				switch operation {
				case .UnaryOperation(_, let f):
					accumulator = f(accumulator)
					internalProgram.append(symbol)
				case .BinaryOperation(let f):
					pending = PendingBinaryOperationInfo(binaryFunction: f, firstOperand: accumulator)
					internalProgram.append(symbol)
				default:
					pending = nil
				}
			}
		}
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
		{	clear()
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
	
	var numberFormatter: NSNumberFormatter?
	
	var description: String {
		var targetString = String()
		for property in internalProgram
		{	if let operand = property as? Double {
				let stringToAppend = numberFormatter?.stringFromNumber(operand) ?? String(operand)
				targetString = targetString + stringToAppend
			}
			else if let symbol = property as? String
			{	if let operation = operations[symbol]
				{	switch operation {
					case .Constant, .Variable, .BinaryOperation:
						targetString = targetString + symbol
					case .UnaryOperation(let printSymbol, _):
						switch printSymbol {
						case .Postfix(let symbol):
							targetString = "(" + targetString + ")" + symbol
						case .Prefix(let symbol):
							targetString = symbol + "(" + targetString + ")"
						}
					case .Equals:
						break
					}
				}
				else {
					targetString = targetString + symbol
				}
			}
		}
		return targetString
	}
	
	func clear() {
		pending = nil
		internalProgram = []
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
	
	private var accumulator = 0.0
	
	private var internalProgram = [AnyObject]()

	private var operations: [String: Operation] = [
		"×"		: Operation.BinaryOperation(*),
		"÷"		: Operation.BinaryOperation(/),  // { $0 / $1 },
		"+"		: Operation.BinaryOperation(+),
		"−"		: Operation.BinaryOperation { $0 - $1 },
		"√"		: Operation.UnaryOperation(.Prefix("√"), sqrt),
		"¹∕ⅹ"	: Operation.UnaryOperation(.Postfix("⁻¹")) { 1/$0 },
		"x²"	: Operation.UnaryOperation(.Postfix("²")) { $0 * $0 },
		"Rand"	: Operation.Constant(drand48()),
		"%"		: Operation.UnaryOperation(.Postfix("%")) { $0 / 100 },
		"sin"	: Operation.UnaryOperation(.Prefix("sin"), sin),
		"cos"	: Operation.UnaryOperation(.Prefix("cos"), cos),
		"tan"	: Operation.UnaryOperation(.Prefix("tan"), tan),
		"±"		: Operation.UnaryOperation(.Postfix("x -1")) { -$0 },
		"π"		: Operation.Constant(M_PI),
		"e"		: Operation.Constant(M_E),
		"="		: Operation.Equals
	]
	
	private enum Operation //: CustomStringConvertible
	{	case Constant(Double)
		case Variable(Double)
		case UnaryOperation(PrintSymbol, Double -> Double)
		case BinaryOperation((Double, Double) -> Double)
		case Equals
		
		enum PrintSymbol {
			case Prefix(String)
			case Postfix(String)
		}
	}
	
	private var pending: PendingBinaryOperationInfo?
	
	private struct PendingBinaryOperationInfo {
		var binaryFunction: (Double, Double) -> Double
		var firstOperand: Double
	}

	private func executePendingBinaryOperation()
	{	if let pending = pending {
			accumulator = pending.binaryFunction(pending.firstOperand, accumulator)
			self.pending = nil
		}
	}
	
}
