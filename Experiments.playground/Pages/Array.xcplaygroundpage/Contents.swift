
extension Array {
    mutating func rotate(positions: Int, size: Int? = nil) {
        let size = size ?? count
        guard positions < count && size <= count else { return }

        self[0..<positions].reverse()
        self[positions..<size].reverse()
        self[0..<size].reverse()
    }
}

var test = [0, 1, 2, 3]
test.rotate(positions: 1)
