import Foundation

var inside = 0.0
var total = 11101.0

for _ in 1...Int(total) {
	// Random coordinates inside the 1x1 square.
	let x = Double.random(in: 0...1)
	let y = Double.random(in: 0...1)
	
	// Check if point is in circle
	if sqrt(pow(x, 2) + pow(y, 2)) < 1 {
		inside += 1
	}
}

// Pi formula is = PercentOfSquareInCircle * AreaOfSquare / Radius^2 (4 in this case)
let 𝝿 = inside / total * 4.0
print(𝝿)
