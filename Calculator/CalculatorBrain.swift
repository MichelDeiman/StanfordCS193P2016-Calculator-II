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
		accumulator = operand
		internalProgram.append(operand)
	}
	
	private var operations: [String: Operation] = [
		"×"		: Operation.BinaryOperation(*),
		"÷"		: Operation.BinaryOperation(/),  // { $0 / $1 },
		"+"		: Operation.BinaryOperation(+),
		"−"		: Operation.BinaryOperation { $1 - $0 },
		"√"		: Operation.UnaryOperation(sqrt),
		"sin"	: Operation.UnaryOperation(sin),
		"cos"	: Operation.UnaryOperation(cos),
		"tan"	: Operation.UnaryOperation(cos),
		"±"		: Operation.UnaryOperation { -$0 },
		"π"		: Operation.Constant(M_PI),
		"e"		: Operation.Constant(M_PI),
		"="		: Operation.Equals
	]
	
	// Operand == contant in 2016
	private enum Operation //: CustomStringConvertible
	{	case Constant(Double)
		case UnaryOperation(Double -> Double)
		case BinaryOperation((Double, Double) -> Double)
		case Equals
	}
	
	func performOperation(symbol: String) {
		if let operation = operations[symbol] {
			internalProgram.append(symbol)
			switch operation {
			case .Constant(let value):
				accumulator = value
			case .UnaryOperation(let f):
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
	
	func clear() {
		accumulator = 0.0
		pending = nil
		internalProgram = []
	}
	
	var result: Double {
		return accumulator
	}
		
}