import AoC_Helpers
import Algorithms

let offsets: [Int] = input().lines().map { line in
	let sign = line.first == "R" ? 1 : -1
	let distance = Int(line.dropFirst())!
	return sign * distance
}

let positions = offsets.reductions(1_000_000_000_50, +) // offset by a bunch so we're always positive
let zeroes = positions.count { $0.isMultiple(of: 100) }
print(zeroes)

let withInterstitials = positions.adjacentPairs().sum { old, new in
	if new > old {
		// going up, hitting zero will increment our multiple of 100
		new / 100 - old / 100
	} else {
		// going down, we don't want to increment on leaving zero but we do want to increment on arriving there.
		// bias by -1 so leaving zero doesn't affect our multiple but arriving there does (by overshooting to 99)
		(old - 1) / 100 - (new - 1) / 100
	}
}
print(withInterstitials)
