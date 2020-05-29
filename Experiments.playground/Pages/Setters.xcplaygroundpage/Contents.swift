import Cocoa

struct Player {
	var name = "player1"
	var totalHands = 0
	
	
}

class Data {
	var players = [Player]() {
		willSet(newPlayer) {
			print("First player: \(newPlayer.first!)")
			// print("old Value: \(oldValue)")
		}
		didSet {
			print("old Value: \(oldValue)")
		}
	}
	
	init() {
		self.players = Array(repeating: Player(), count: 6)
		//self.players = [:]
	}
}

var dat = Data()

dat.players[0].totalHands += 1

