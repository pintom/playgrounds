//
//  Cards.swift
//  Poker
//
//  Created by tom on 01/10/2019.
//  Copyright © 2019 Tomas Tirlikas. All rights reserved.
//

import Foundation

public typealias Cards = Array<Card>

public extension Cards {
	
	func evaluate() throws -> HandRank {

		if self.count < 5 {
			throw HandRankError.invalidHand("less than 5 cards")
		} else if self.count > 5 {
			throw HandRankError.invalidHand("more than 5 cards")
		}
		
		let c1 = self[0].bitPattern
		let c2 = self[1].bitPattern
		let c3 = self[2].bitPattern
		let c4 = self[3].bitPattern
		let c5 = self[4].bitPattern
		
		let q = (c1 | c2 | c3 | c4 | c5) >> 16
		
		// Check for flush
		let isFlush = c1 & c2 & c3 & c4 & c5 & 0xF000 // if flush, then != 0
		if isFlush != 0 {
			let f = flushes[Int(q)]
			do {
				let ret = try handValue(val: f)
				return ret
			} catch {
				throw HandRankError.invalidHand("cant find value in flushes")
			}
		}
		
		// If not a flush
		// If the value found there is zero, then we do not have a Straight or High Card
		let un = uniqueToRanks[Int(q)]

		if un != 0 {
			do {
				let ret = try handValue(val: un)
				return ret
			} catch {
				throw HandRankError.invalidHand("can't find value in uniqueToRanks")
			}
		}
		
		
		// If still not found
		// Extract prime number value and multiply them together
		let l = (c1 & 0xFF) * (c2 & 0xFF) * (c3 & 0xFF) * (c4 & 0xFF) * (c5 & 0xFF)

		guard let t = products.firstIndex(of: Int(l)) else { throw HandRankError.invalidHand("error: t nil value, l = \(l)")}
		let o = values[t]

		do {
			let ret = try handValue(val: o)
			return ret
		} catch {
			throw HandRankError.invalidHand("can't find value in values")
		}
	}
	
	enum HandRankError: Error {
		case invalidHand(String)
	}
	
	enum HandRank: String {
		case highCard, onePair, twoPairs, threeOfAKind, straight, flush, fullHouse, fourOfAKind, straightFlush
	}
	
	private func handValue(val: Int) throws -> HandRank {
		if val > 6185 { return .highCard }
		if val > 3325 { return .onePair }
		if val > 2467 { return .twoPairs }
		if val > 1609 { return .threeOfAKind }
		if val > 1599 { return .straight }
		if val > 322 { return .flush }
		if val > 166 { return .fullHouse }
		if val > 10 { return .fourOfAKind }
		if val > 0 { return .straightFlush }
		throw HandRankError.invalidHand("hand value: \(val)")
	}
	
	/// Returns a shuffled deck of cards.
	func deck() -> Cards {
		var d = Cards()
		
		
		for s in Card.Suit.allCases {
			for r in Card.Rank.allCases {
				d.append(Card(r: r, s: s))
			}
		}
		
		d.shuffle()
		return d
	}
	
	var suited: Bool {
		let suit = self.first?.suit
		for i in self {
			if i.suit != suit {
				return false
			}
		}
		return true
	}
	
	/// For example: AKs or 45o
	var abstractRepresetation: String {
		var st = ""
		for i in self {
			st += i.rank!.string.description
		}
		
		if self.suited {
			st += "s"
		} else {
			st += "o"
		}
		return st
	}
	
	
}


