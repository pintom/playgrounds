
let a: UInt32 = 0b00000010000000001000100100011101

let o: UInt32 = 0b00000000000000000000000001011000
String(o, radix: 2)

let one: UInt32 = 88
String(repeating: "0", count: one.leadingZeroBitCount) + String(one, radix: 2)

let two: UInt32 = 44
String(repeating: "0", count: two.leadingZeroBitCount) + String(two, radix: 2)

let three: UInt32 = one & two & o & a
String(repeating: "0", count: three.leadingZeroBitCount) + String(three, radix: 2)

let four: UInt32 = three>>1
String(repeating: "0", count: four.leadingZeroBitCount) + String(four, radix: 2)

