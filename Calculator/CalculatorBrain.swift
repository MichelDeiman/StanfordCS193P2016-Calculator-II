//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michel Deiman on 09/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import Foundation

class CalculatorBrain
{
	
	private enum Op: CustomStringConvertible
	{	case Operand(Double)
		case Constant(String, Double)
		case UnaryOperation(String, Double -> Double)
		case BinaryOperation(String, (Double, Double) -> Double)
		
		var description: String
		{	switch self
			{	case .Operand(let operand):
					return "\(operand)"
				case .Constant(let symbol, _):
					return symbol
				case .UnaryOperation(let symbol, _):
					return symbol
				case .BinaryOperation(let symbol, _):
					return symbol
			}
		}
	}
	
	private var opStack = [Op]()
	private var knownOps = [String: Op]()
	
	init()
	{	knownOps["×"] 	= Op.BinaryOperation("x", *)
		knownOps["÷"] 	= Op.BinaryOperation("÷") { $1 / $0 }
		knownOps["+"] 	= Op.BinaryOperation("+", +)
		knownOps["−"] 	= Op.BinaryOperation("-") { $0 - $1 }
		knownOps["√"] 	= Op.UnaryOperation("√", sqrt)
		knownOps["sin"]	= Op.UnaryOperation("sin", sin)
		knownOps["cos"]	= Op.UnaryOperation("cos", cos)
		knownOps["π"]	= Op.Constant("π", M_PI)
	}
	
	private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
	{	guard !ops.isEmpty else { return (nil, ops) }
		var remainingOps = ops
		let op = remainingOps.removeLast()
		switch op
		{	case .Operand(let operand):
				return (operand, remainingOps)
			case .Constant(_, let operand):
				return (operand, remainingOps)
			case .UnaryOperation(_, let operation):
				let operandEvaluation = evaluate(remainingOps)
				if let operand = operandEvaluation.result
				{	return (operation(operand), operandEvaluation.remainingOps)
				}
			
			case .BinaryOperation(_, let operation):
				let operand1Evaluation = evaluate(remainingOps)
				if let operand1 = operand1Evaluation.result
				{	let operand2Evaluation = evaluate(operand1Evaluation.remainingOps)
					if let operand2 = operand2Evaluation.result
					{	return (operation(operand1, operand2), operand2Evaluation.remainingOps)
					}
				}
		}
		return (nil, ops)
	}
	
	func evaluate() -> Double?
	{	let (result, remainder) = evaluate(opStack)
		print("\(opStack) = \(result) with \(remainder) left over")
		return result
	}
	
	func pushOperand(operand: Double) -> Double?
	{	opStack.append(Op.Operand(operand))
		return evaluate()
	}
	
	func performOperation(symbol: String) -> Double?
	{	if let operation = knownOps[symbol]
		{	opStack.append(operation)
		}
		return evaluate()
	}
	
	func clearStack()
	{	opStack = []
	}
	
}