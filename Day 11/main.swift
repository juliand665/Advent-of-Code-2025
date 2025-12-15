import AoC_Helpers
import Foundation

let neighbors: [String: [String]] = Dictionary(uniqueKeysWithValues: input().lines().map { line -> (String, [String]) in
	line.split(separator: ": ").splat { (String($0), $1.components(separatedBy: " ")) }
})
print(Set(neighbors.values.joined()).count)

var numPathsByTarget: [String: [String: Int]] = [:]
func numPaths(from source: String, to target: String) -> Int {
	guard source != target else { return 1 }
	if let existing = numPathsByTarget[target]?[source] {
		return existing
	} else {
		let num = (neighbors[source] ?? []).sum { numPaths(from: $0, to: target) }
		numPathsByTarget[target, default: [:]][source] = num
		return num
	}
}
print(numPaths(from: "you", to: "out"))

let fftFirst = numPaths(from: "svr", to: "fft") * numPaths(from: "fft", to: "dac") * numPaths(from: "dac", to: "out")
let dacFirst = numPaths(from: "svr", to: "dac") * numPaths(from: "dac", to: "fft") * numPaths(from: "fft", to: "out")
print(fftFirst + dacFirst)
