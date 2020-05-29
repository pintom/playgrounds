import Foundation

// Roulette simulates Four roulette of 36 pockets and no 0.
// Winnings are calculated by multiplying bet amount by 35.
class Roulette {
	var description: String
	var pockets: [Int]
	var ball: Int
	let pocketOdds: Int
	
	init() {
		description = "Fair Roulette"
		pockets = Array(1...36)
		ball = 0
		pocketOdds = pockets.count - 1
	}
	
	func spin() {
		ball = pockets.randomElement()!
	}
	
	func bet(pocket: Int, bet: Int) -> Int {
		if pocket == ball {
			return bet * pocketOdds
		} else {
			return -bet
		}
	}
	
	
}

func playRoulette(game: Roulette, numberOfSpins: Int, pocket: Int, bet: Int, printOn: Bool = false) -> Double {
	var totalPocket = 0
	for _ in 0...numberOfSpins {
		game.spin()
		totalPocket += game.bet(pocket: pocket, bet: bet)
	}
	if printOn {
		print("\(numberOfSpins) spins of \(game.description)")
		print("Expected return betting \(pocket) = \(Double(totalPocket)/Double(numberOfSpins)*100)%\n")
	}
	return Double(totalPocket) / Double(numberOfSpins)
}

let rl = Roulette()
for numSpins in [100,1000] {
	for _ in 1...3 {
		_ = playRoulette(game: rl, numberOfSpins: numSpins, pocket: 2, bet: 1, printOn: true)
	}
}

// Same as fair roulette but with added 0.
class EuropeanRoulette: Roulette {
	override init() {
		super.init()
		pockets.append(0)
		description = "European Roulette"
	}
}

// Same as european roulette bit with added 00 (another 0 for simplicity).
class AmericanRoulette: EuropeanRoulette {
	override init() {
		super.init()
		pockets.append(00)
		description = "American Roulette"
	}
}

func findPocketReturn(game: Roulette, numTrials: Int, trialSize: Int) -> [Double] {
	var pocketReturns = [Double]()
	for _ in 1...numTrials {
		let trialVals = playRoulette(game: game, numberOfSpins: trialSize, pocket: 2, bet: 1)
		pocketReturns.append(trialVals)
	}
	return pocketReturns
}

func meanAndStandartDev(_ x: [Double]) -> (Double, Double) {
	let mean = x.reduce(0, +) / Double(x.count)
	var tot = 0.0
	for n in x {
		tot += pow((n - mean), 2)
	}
	let std = pow((tot / Double(x.count)), 0.5)
	return (mean, std)
}

let numTrials = 20
var resultDict = [String : [Int]]()

let eurl = EuropeanRoulette()
let amrl = AmericanRoulette()

let games: [Roulette] = [rl, eurl, amrl]

for G in games {
	resultDict[G.description] = []
}

for numSpins in [1000, 10000, 100000, 1000000] {
	print("\nSimulate \(numTrials) trials of \(numSpins) spins each")
	for G in games {
		let pocketReturns = findPocketReturn(game: G, numTrials: numTrials, trialSize: numSpins)
		//let expReturns = 100 * pocketReturns.reduce(0, +) / Double(pocketReturns.count)
		let (mean, std) = meanAndStandartDev(pocketReturns)
		print("Exp. return for \(G.description) = \((100 * mean * 1000).rounded() / 1000)% +-\((100*1.96*std * 1000).rounded()/1000) with 95% confidence")
	}
}

// Output:
//
//	100 spins of Fair Roulette
//	Expected return betting 2 = 114.99999999999999%
//
//	100 spins of Fair Roulette
//	Expected return betting 2 = 7.000000000000001%
//
//	100 spins of Fair Roulette
//	Expected return betting 2 = -28.999999999999996%
//
//	1000 spins of Fair Roulette
//	Expected return betting 2 = -2.9000000000000004%
//
//	1000 spins of Fair Roulette
//	Expected return betting 2 = -38.9%
//
//	1000 spins of Fair Roulette
//	Expected return betting 2 = 18.7%
//
//
//	Simulate 20 trials of 1000 spins each
//	Exp. return for Fair Roulette = -2.54% +- 32.404 with 95% confidence
//	Exp. return for European Roulette = -0.92% +- 33.653 with 95% confidence
//	Exp. return for American Roulette = -9.56% +- 27.444 with 95% confidence
//
//	Simulate 20 trials of 10000 spins each
//	Exp. return for Fair Roulette = -1.73% +- 8.532 with 95% confidence
//	Exp. return for European Roulette = -1.154% +- 7.808 with 95% confidence
//	Exp. return for American Roulette = -7.058% +- 9.397 with 95% confidence
//
//	Simulate 20 trials of 100000 spins each
//	Exp. return for Fair Roulette = 0.038% +- 3.313 with 95% confidence
//	Exp. return for European Roulette = -2.148% +- 3.34 with 95% confidence
//	Exp. return for American Roulette = -4.759% +- 3.443 with 95% confidence
//
//	Simulate 20 trials of 1000000 spins each
//	Exp. return for Fair Roulette = 0.089% +- 0.925 with 95% confidence
//	Exp. return for European Roulette = -2.614% +- 1.304 with 95% confidence
//	Exp. return for American Roulette = -5.362% +- 1.094 with 95% confidence

