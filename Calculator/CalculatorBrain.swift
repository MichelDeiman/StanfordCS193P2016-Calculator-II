//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michel Deiman on 11/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import Foundation

class CalculatorBrain  {
	
	private var accumulator = 0.0
	private var internalProgram = [AnyObject]()
	
	func setOperand(operand: Double) {
		if pending == nil {
			clear()
		}
		accumulator = operand
		internalProgram.append(operand)
	}
	
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
	
	// Operand == contant in 2016
	private enum Operation //: CustomStringConvertible
	{	case Constant(Double)
		case UnaryOperation(PrintSymbol, Double -> Double)
		case BinaryOperation((Double, Double) -> Double)
		case Equals
	
		enum PrintSymbol {
			case Prefix(String)
			case Postfix(String)
		}
	}
	
	func performOperation(symbol: String) {
		if let operation = operations[symbol] {
			internalProgram.append(symbol)
			switch operation {
			case .Constant(let value):
				accumulator = value
			case .UnaryOperation(_, let f):
				accumulator = f(accumulator)
			case .BinaryOperation(let f):
				executePendingBinaryOperation()
				pending = PendingBinaryOperationInfo(binaryFunction: f, firstOperand: accumulator)
			case .Equals:
				executePendingBinaryOperation()
			}
		}
	}
	
	private func executePendingBinaryOperation()
	{	if let pending = pending {
			accumulator = pending.binaryFunction(pending.firstOperand, accumulator)
			self.pending = nil
		}
	}
	
	var isPartialResult: Bool
	{	return pending != nil
	}
	
	private var pending: PendingBinaryOperationInfo?
	
	private struct PendingBinaryOperationInfo {
		var binaryFunction: (Double, Double) -> Double
		var firstOperand: Double
	}
	
	var numberFormatter: NSNumberFormatter?
	
	var description: String {
		var targetString = ""
		for property in internalProgram
		{	if let operand = property as? Double {
				let stringToAppend = numberFormatter?.stringFromNumber(operand) ?? String(operand)
				targetString = targetString + stringToAppend
			} else if let symbol = property as? String
			{	if let operation = operations[symbol]
				{	switch operation {
					case .Constant, .BinaryOperation:
						targetString = targetString + symbol
					case .UnaryOperation(let printSymbol, _):
						switch printSymbol {
						case .Postfix(let symbol):
							targetString = "(" + targetString + ")" + symbol
						case .Prefix(let symbol):
							targetString = symbol + "(" + targetString + ")"
						}
					default:
						break
					}
				}
			}
		}
		return targetString
	}
	
	func clear() {
		accumulator = 0.0
		pending = nil
		internalProgram = []
	}
	
	var result: Double {
		return accumulator
	}
		
}
