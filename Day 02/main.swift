import Foundation
import AoC_Helpers
import Algorithms

let ranges = input().components(separatedBy: ",").map { $0.ints().splat(...) }

func repeats(ofCount count: Int, in range: ClosedRange<Int>) -> some Sequence<Int> {
	let bases = sequence(first: 10) { $0 * 10 }.lazy.map { power in
		// (11, 0..<9)
		// (101, 9..<99)
		// etc.
		let modulus = (1..<count).reduce(1) { acc, _ in acc * power + 1 }
		return (modulus: modulus, validMults: (power / 10)..<power)
	}
	return bases
		.prefix { range.upperBound / $0.modulus >= $0.validMults.lowerBound }
		.flatMap { modulus, validMults in
			let foundMults = ((range.lowerBound - 1) / modulus + 1)..<(range.upperBound / modulus + 1)
			return foundMults.intersection(with: validMults)?.map { $0 * modulus } ?? []
		}
}

func simpleRepeats(in range: ClosedRange<Int>) -> some Sequence<Int> {
	repeats(ofCount: 2, in: range)
}

print(ranges.flatMap(simpleRepeats(in:)).sum())

func allRepeats(in range: ClosedRange<Int>) -> some Sequence<Int> {
	(2...range.upperBound.digits().count).lazy.flatMap {
		repeats(ofCount: $0, in: range)
	}.uniqued()
}

print(ranges.flatMap(allRepeats(in:)).sum())
