//
//  Card.swift
//  Poker
//
//  Created by tom on 19/09/2019.
//  Copyright © 2019 Tomas Tirlikas. All rights reserved.
//

import Foundation

public struct Card: CustomStringConvertible {
	/// Human readable card description.
	public var description: String {
		return humanString
	}
	
	/// Initializes card from one letter i.e  Z = A♠️.
	init(character letter: Character) {
		abcString = letter
		humanString = String()
		abcStringDecode()
		
	}
	
	/// Initializez card from human readable string i.e A♠️.
	public init(_ card: String) {
//		if card.count != 2 {
//			return nil
//		}
		humanString = card
		abcString = "X"
		humanToAbc()
	}
	
	/// Initializes card giving rank and suite.
	init(r: Rank, s: Suit) {
		rank = r
		suit = s
		
		abcString = Character(".")
		humanString = String()
		
		rstoStrings()
		
	}
	
	private var abcString: Character
	private var humanString: String
	
	var rank: Rank?
	var suit: Suit?
	
	/// Bit pattern representing unique card: 00001000 00000000 01001011 00100101 - (134236965) - is K♦️.
	public var bitPattern: UInt32 {
		return  rank!.prime | rank!.rawValue<<8 | rank!.rankBit | suit!.rawValue
	}
	
	// Card bits is an integer, made up of four bytes.  The high-order
	// bytes are used to hold the rank bit pattern, whereas
	// the low-order bytes hold the suit/rank/prime value
	// of the card.
	
	//  xxxAKQJT 98765432 CDHSrrrr xxPPPPPP
	// +--------+--------+--------+--------+
	// |xxxbbbbb|bbbbbbbb|cdhsrrrr|xxpppppp|
	// +--------+--------+--------+--------+
	//
	// p = prime number of rank (deuce=2,trey=3,four=5,five=7,...,ace=41)
	// r = rank of card (deuce=0,trey=1,four=2,five=3,...,ace=12)
	// cdhs = suit of card
	// b = bit turned on depending on rank of card
	// ©Kevin Suffecool http://suffe.cool/poker/evaluator.html
	
	enum Rank: UInt32, CaseIterable {
	
		// r = rank of card (deuce=0,trey=1,four=2,five=3,...,ace=12), needs to be shifted by << 8
		case two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace

		
		var string: Character {
			switch self {
			case .two: return "2"; case .three: return "3";
			case .four:	return "4"; case .five:	return "5"; case .six: return "6";
			case .seven: return "7"; case .eight: return "8"; case .nine: return "9";
			case .ten: return "T"; case .jack: return "J"; case .queen:	return "Q";
			case .king:	return "K"; case .ace: return "A"
			}
		}
		
		/// xxxAKQJT 98765432 CDHSrrrr xxPPPPPP
		var rankBit: UInt32 {
			switch self {
			case .two: return 65536; case .three: return 131072;
			case .four:	return 262144; case .five: return 524288;
			case .six: return 1048576; case .seven: return 2097152;
			case .eight: return 4194304; case .nine: return 8388608;
			case .ten: return 16777216; case .jack: return 33554432;
			case .queen: return 67108864; case .king: return 134217728;
			case .ace: return 268435456
			}
		}
		
		var prime: UInt32 {
			switch self {
			case .two: return 2; case .three: return 3;
			case .four:	return 5; case .five: return 7;
			case .six: return 11; case .seven: return 13;
			case .eight: return 17; case .nine: return 19;
			case .ten: return 23; case .jack: return 29;
			case .queen: return 31; case .king:	return 37;
			case .ace: return 41
			}
		}
		
	}
	
	enum Suit: UInt32, CaseIterable {
		case clubs = 32768, diamonds = 16384, hearts = 8192, spades = 4096
		var string: Character {
			switch self {
			case .spades: return "♠️";
			case .hearts: return "♥️";
			case .diamonds: return "♦️";
			case .clubs: return "♣️";
			}
		}
	}
	
	private mutating func rstoStrings() {
		var c: String = ""
		
		c.append(rank!.string)
		c.append(suit!.string)
		
		humanString = c
		
		for (k, v) in cDecoder {
			if v == humanString {
				abcString = Character(k)
			}
		}
		
	}
	
	private mutating func humanToAbc() {
		for (k, v) in cDecoder {
			if v == humanString {
				abcString = Character(k)
			}
		}
		rankSuit()
	}
	
	private mutating func abcStringDecode() {
		humanString = cDecoder[String(abcString)] ?? "XX"
		rankSuit()
	}
	
	private mutating func rankSuit() {
		let x = (humanString[humanString.startIndex], humanString[humanString.index(after: humanString.startIndex)])
		
		switch x {
		case (_, "♣️"): suit = .clubs
		case (_, "♦️"): suit = .diamonds
		case (_, "♥️"): suit = .hearts
		case (_, "♠️"): suit = .spades
		default: print("Card.stringDecode Error: \(String(describing: abcString))")
		}
		
		switch x {
		case ("2", _): rank = .two
		case ("3", _): rank = .three
		case ("4", _): rank = .four
		case ("5", _): rank = .five
		case ("6", _): rank = .six
		case ("7", _): rank = .seven
		case ("8", _): rank = .eight
		case ("9", _): rank = .nine
		case ("T", _): rank = .ten
		case ("J", _): rank = .jack
		case ("Q", _): rank = .queen
		case ("K", _): rank = .king
		case ("A", _): rank = .ace
		default: print("Card.stringDecode Error: \(String(describing: abcString))")
			
		}
	}
	
	private let cDecoder: [String : String] = [
		"a": "2♣️", "b": "3♣️", "c": "4♣️", "d": "5♣️", "e": "6♣️", "f": "7♣️",
		"g": "8♣️", "h": "9♣️", "i": "T♣️", "j": "J♣️", "k": "Q♣️", "l": "K♣️", "m": "A♣️",
		"n": "2♦️", "o": "3♦️", "p": "4♦️", "q": "5♦️", "r": "6♦️", "s": "7♦️",
		"t": "8♦️", "u": "9♦️", "v": "T♦️", "w": "J♦️", "x": "Q♦️", "y": "K♦️", "z": "A♦️",
		"A": "2♥️", "B": "3♥️", "C": "4♥️", "D": "5♥️", "E": "6♥️", "F": "7♥️",
		"G": "8♥️", "H": "9♥️", "I": "T♥️", "J": "J♥️", "K": "Q♥️", "L": "K♥️", "M": "A♥️",
		"N": "2♠️", "O": "3♠️", "P": "4♠️", "Q": "5♠️", "R": "6♠️", "S": "7♠️",
		"T": "8♠️", "U": "9♠️", "V": "T♠️", "W": "J♠️", "X": "Q♠️", "Y": "K♠️", "Z": "A♠️",
	]
}
