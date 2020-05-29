
class Kuhn {
	
	enum Actions: Int, CaseIterable {
		case pass, bet
	}
	
	enum Cards: Int {
		case queen, king, ace
		
		var description: String {
			switch self {
			case.ace: return "Ace"
			case.king: return "King"
			case.queen: return "Queen"
			}
		}
	}
	
	static let NUM_ACTIONS = Actions.allCases.count

	class Node {
		// infoSet contains representation of the information set
		var infoSet = ""
		
		var regretSum = Array(repeating: 0.0, count: NUM_ACTIONS)
		//var strategy = Array(repeating: 0.0, count: NUM_ACTIONS)
		var strategySum = Array(repeating: 0.0, count: NUM_ACTIONS)
		
		func toString() -> String {
			let st = getAverageStrategy()
			//return "[\((st.first! * 1000).rounded()/1000), \((st.last! * 1000).rounded()/1000)]"
			return "\(st)"
		}
		
		// Get current mixed strategy through regret-matching.
		func getStrategy(realizationWeight: Double) -> [Double] {
			var strategy = Array(repeating: 0.0, count: NUM_ACTIONS)
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
				strategySum[i] += realizationWeight * strategy[i]
			}
			
			return strategy
		}
		
		// Get average mixed strategy across all training iterations
		private func getAverageStrategy() -> [Double] {
			regretSum = Array(repeating: 0.0, count: NUM_ACTIONS)

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
			
			return avgStrategy
		}
	}
	
	// nodeMap stores information sets with string key value.
	var nodeMap = [String : Node]()
	
	// Counterfactual regret minimization iteration
	func cfr(cards: [Cards], history: String, p0: Double, p1: Double) -> Double {
		let plays = history.count
		let player: Int = plays % 2 // player 0 or player 1
		let opponent = 1 - player
		
		// Return payoff for terminal states
		if plays > 1 {
			// terminal - game has ended
			let terminalPass: Bool = history[history.index(before:history.endIndex)] == "p"
			// There was a bet and a call
			let doubleBet: Bool = history[history.index(history.endIndex, offsetBy: -2)..<history.endIndex] == "bb"
			// Did player win
			let isPlayerCardHigher: Bool = cards[player].rawValue > cards[opponent].rawValue
			
			if terminalPass {
				if history == "pp" {
					return isPlayerCardHigher ? 1 : -1
				} else { // player folded
					return 1
				}
			} else if doubleBet {
				return isPlayerCardHigher ? 2 : -2
			}
		}
		
		let infoSet = cards[player].description + " " + history
		
		// Get information set node or create it if nonexistant
		var node = nodeMap[infoSet]
		if node == nil {
			node = Node()
			node!.infoSet = infoSet
			
			nodeMap[infoSet] = node
		}
	
		// For each action, recursively call cfr with additional history and probability.
		let strategy: [Double] = node!.getStrategy(realizationWeight: player == 0 ? p0 : p1)
		var util = Array(repeating: 0.0, count: Kuhn.NUM_ACTIONS)
		var nodeUtil: Double = 0.0
		for i in 0..<Kuhn.NUM_ACTIONS {
			let nextHistory: String = history + (i == 0 ? "p" : "b") // p - pass, b - bet
			util[i] = player == 0 ? cfr(cards: cards, history: nextHistory, p0: p0 * strategy[i], p1: p1) : cfr(cards: cards, history: nextHistory, p0: p0, p1: p1 * strategy[i])
			nodeUtil += strategy[i] * util[i]
		}
		
		// For each action, compute and accumulate counterfactual regret.
		for i in 0..<Kuhn.NUM_ACTIONS {
			let regret: Double = util[i] - nodeUtil
			node!.regretSum[i] += (player == 0 ? p1 : p0) * regret
		}
				
		return nodeUtil
	}
	
	func train(iterations: Int) {
		var cards: [Cards] = [.ace, .king, .queen]
		var util = 0.0
//		cards.shuffle()
//		print(cards)
		
		for _ in 0..<iterations {
			cards.shuffle()
			util += cfr(cards: cards, history: "", p0: 1, p1: 1)
		}
		
		print("Average game value: \(util / Double(iterations))")
		let sortedKey = Array(nodeMap.keys).sorted()
		for i in sortedKey {
			print("\(i)  \t\t\(nodeMap[i]!.toString())")
		}
		
//		for (k, v) in nodeMap {
//			print("\(k): \(v.toString())")
//		}
//
		
	}
	
	init() {
		let iterations = 10000
		print("Iterations: \(iterations)")
		
		train(iterations: iterations)
		
	}
}

let ku = Kuhn()

//let history = ""
//let terminalPass = history[history.index(before:history.endIndex)]
//let two = history[history.index(history.endIndex, offsetBy: -2)..<history.endIndex]
//
//let plays = history.count
//let player: Int = plays % 2
