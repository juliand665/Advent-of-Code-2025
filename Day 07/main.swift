import AoC_Helpers

let map = Matrix(input().lines())
let start = map.rows.first!.onlyIndex(of: "S")!

var positions: [Int: Int] = [start: 1] // number of timeline leading to each position
var splits = 0
for line in map.rows.dropFirst() {
	let splitters = line.indices.filter { line[$0] == "^" }
	for split in splitters {
		guard let timelines = positions[split] else { continue }
		splits += 1
		positions[split] = nil
		positions[split - 1, default: 0] += timelines
		positions[split + 1, default: 0] += timelines
	}
}
print(splits)
print(positions.values.sum())
