//: [Previous](@previous)

import Foundation

var str = "Hel o o "
var st = str.replacingOccurrences(of: " ", with: "")

st.count

let int = "1234"

extension String {
	var stArray: [String] {
		var arr = [String]()
		for s in self {
			arr.append(s.description)
		}
		return arr
	}
}

let arrInt = int.stArray
//: [Next](@next)
