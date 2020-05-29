// http://modelai.gettysburg.edu/2013/cfr/cfr.pdf

import Foundation
import Accelerate

enum RPS: Int, CaseIterable {
	case rock, paper, scissors
}

// Evaluetas the Rock, Paper, Scissors game and returns if player1 won (1), lost (-1) or it is a draw (0).
func evaluate(player1: RPS, player2: RPS) -> Int {
	if player1 == player2 {
		return 0
	} else if player1 == .rock && player2 == .scissors {
		return 1
	} else if player1 == .paper && player2 == .rock {
		return 1
	} else if player1 == .scissors && player2 == .paper {
		return 1
	} else {
		return -1
	}
}

class RPSAgent {
	private let NUM_ACTIONS = RPS.allCases.count
	
	var strategy = [0.0, 0.0, 0.0]
	var regretSum = [0.0, 0.0, 0.0]
	var strategySum = [0.0, 0.0, 0.0]
	var oppStrategy = [0.0, 0.0, 0.0]
	var oppStrategySum = [0.0, 0.0, 0.0]
	
	// Get current mixed strategy through regret-matching.
	private func getStrategy() {
		var normalizingSum = 0.0
		
		for i in 0..<NUM_ACTIONS {
			strategy[i] = regretSum[i] > 0 ? regretSum[i] : 0
			normalizingSum += strategy[i]
		}
		
		for i in 0..<NUM_ACTIONS {
			if normalizingSum > 0 {
				strategy[i] /= normalizingSum
			} else {
				strategy[i] = 1.0 / Double(NUM_ACTIONS)
			}
			strategySum[i] += strategy[i]
		}
	}
	
	// Get random action according to mixed strategy distribution.
	func getAction(_ str: [Double]? = nil) -> RPS {
		var s = [Double]()
		if str == nil {
			s = strategy
		} else {
			s = str!
		}
		
		let r = Double.random(in: 0...1)
		var a = 0
		var cumulativeProbability = 0.0
		
		while a < NUM_ACTIONS - 1 {
			cumulativeProbability += s[a]
			if r < cumulativeProbability {
				break
			}
			a += 1
		}
		
		return RPS(rawValue: a)!
	}
	
	// Update the oponent's strategy
	func gotResult(of: RPS) {
		oppStrategySum[of.rawValue] += 1

		// Total sum of opponent actions
		let totalOppSum = oppStrategySum.reduce(0, +)
		
		for i in 0..<NUM_ACTIONS {
			oppStrategy[i] = oppStrategySum[i] / totalOppSum
		}
		
		train(10)
		getAverageStrategy()
	}
	
	private func train(_ iterations: Int) {
		var actionUtility = Array(repeating: 0.0, count: NUM_ACTIONS)
		
		regretSum = Array(repeating: 0.0, count: NUM_ACTIONS)
		//strategySum = Array(repeating: 0.0, count: NUM_ACTIONS)
		
		for _ in 0..<iterations {
			// Get regret-matched mixed-strategy actions
			getStrategy()
			let myAction = getAction(strategy)
			let opAction = getAction(oppStrategy)
			
			// Compute action utilities
			actionUtility[opAction.rawValue] = 0
			actionUtility[opAction.rawValue == NUM_ACTIONS - 1 ? 0 : opAction.rawValue + 1] = 1
			actionUtility[opAction.rawValue == 0 ? NUM_ACTIONS - 1 : opAction.rawValue - 1] = -1
			
			// Accumulate action regrets
			for i in 0..<NUM_ACTIONS {
				regretSum[i] += actionUtility[i] - actionUtility[myAction.rawValue]
			}
			
			
		}
	}
	
	// Get average mixed strategy across all training iterations
	private func getAverageStrategy() {
		var avgStrategy = Array(repeating: 0.0, count: NUM_ACTIONS)
		var normalizingSum = 0.0
		
		for i in 0..<NUM_ACTIONS {
			normalizingSum += strategySum[i]
		}
		
		for i in 0..<NUM_ACTIONS {
			if normalizingSum > 0 {
				avgStrategy[i] = strategySum[i] / normalizingSum
			} else {
				avgStrategy[i] = 1.0 / Double(NUM_ACTIONS)
			}
		}
		
		strategy = avgStrategy
	}
	

}

let p1 = RPSAgent()
let p2 = RPSAgent()

// Tracks player 1 losses or gains
var sum = 0.0
var sumArray = [Double]()

// Sumilate heads up game
let startTime = Date()
//p1.gotResult(of: .rock)
for _ in 0..<1000 {
	let g1 = p1.getAction()
	let g2 = p2.getAction()
	sum += Double(evaluate(player1: g1, player2: g2))
	sumArray.append(sum)
	p1.gotResult(of: g2)
	p2.gotResult(of: g1)

	var mean: Double = 0.0

	vDSP_meanvD(sumArray, 1, &mean, vDSP_Length(sumArray.count))

	print(
	"""
		moves:   \t\(g1) ## \(g2)
		strategy:\t\(p1.strategy) ## \(p2.strategy)
		regretSum:\t\(p1.regretSum) ## \(p2.regretSum)
		strategySum:\t\(p1.strategySum) ## \(p2.strategySum)
		oppStrategy:\t\(p1.oppStrategy) ## \(p2.oppStrategy)
		oppStrategySum:\t\(p1.oppStrategySum) ## \(p2.oppStrategySum)
		p1 balance: \(sum)
		time Elapsed: \(startTime.timeIntervalSinceNow.description)
		mean: \(mean)\n
	""")
	
}

//	strategy:	[0.3482429622494818, 0.3253771308963178, 0.3263799068542003] [0.30878417098538863, 0.3337957933453699, 0.3574200356692414]
//
//	regretSum:	[2.0, -9.0, -8.0] [3.0, 4.0, 2.0]
//
//	strategySum:	[3482429.622582062, 3253771.3090446936, 3263799.06862377] [3087841.709930584, 3337957.933536609, 3574200.356781192]
//
//	oppStrategy:	[0.315584, 0.327212, 0.357204] [0.336001, 0.345512, 0.318487]
//
//	oppStrategySum:	[315584.0, 327212.0, 357204.0] [336001.0, 345512.0, 318487.0]
//
//	p1 balance: 962
//	time Elapsed: -182.75620198249817


