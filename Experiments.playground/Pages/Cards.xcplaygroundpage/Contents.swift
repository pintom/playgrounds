//import Foundation

let c = Cards().deck()

let card = Card("Q♦️")
card.bitPattern
let cards: Cards = [Card("T♥️"), Card("Q♥️"), Card("J♥️"), Card("K♥️"), Card("9♣️")]
try cards.evaluate()
let cards2: Cards = [Card("T♥️"), Card("Q♥️"), Card("J♥️"), Card("K♥️"), Card("A♥️")]
try cards2.evaluate()
let cards3: Cards = [Card("T♥️"), Card("Q♥️"), Card("4♥️"), Card("K♥️"), Card("9♣️")]
try cards3.evaluate()
let cards4: Cards = [Card("A♦️"), Card("A♥️"), Card("A♠️"), Card("A♣️"), Card("K♣️")]
try cards4.evaluate()
let cards5: Cards = [Card("T♥️"), Card("Q♥️"), Card("J♥️"), Card("K♥️"), Card("9♣️")]
try cards5.evaluate()
var cards6: Cards = [Card("7♥️"), Card("9♥️"), Card("J♥️"), Card("J♥️"), Card("9♣️")]
try cards6.evaluate()

cards6.count

cards6 = cards6.filter { $0.description == "7♥️"}

cards6.count
cards6
//

////UInt32.max
