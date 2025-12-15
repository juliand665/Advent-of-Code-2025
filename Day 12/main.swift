import AoC_Helpers

struct Tree {
	var size: Vector2
	var targetCounts: [Int]
}

let groups = input().lineGroups()
let presents = groups.dropLast().map {
	Matrix($0.dropFirst()).map { $0 == "#" }
}
let trees = groups.last!.map {
	let ints = $0.ints()
	return Tree(size: .init(ints[0], ints[1]), targetCounts: Array(ints.dropFirst(2)))
}

let possible = trees.count { tree in
	guard (tree.size.x / 3) * (tree.size.y / 3) < tree.targetCounts.sum() else {
		// trivially possible: could fit even if every single present was 3x3
		return true
	}
	let tilesToPlace = zip(tree.targetCounts, presents).sum { $0 * $1.count(of: true) }
	guard tilesToPlace <= tree.size.product else {
		// trivially impossible: need to place more tiles than we have space for
		return false
	}
	
	// difficult: need to try out concrete placements
	fatalError()
}
print(possible)
