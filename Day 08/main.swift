import AoC_Helpers
import SimpleParser
import Algorithms

extension Vector3 {
	func squaredDistance(to other: Self) -> Int {
		let d = (self - other)
		return d.x * d.x + d.y * d.y + d.z * d.z
	}
}

let positions = input().lines().map(Vector3.init)

let distances = measureTime {
	positions.indices
		.pairwiseCombinations()
		.filter { $0 < $1 }
		.map { (source: $0, target: $1, distance: positions[$0].squaredDistance(to: positions[$1])) }
		.sorted(on: \.distance)
}

// i really need to pull out a union-find data structure

var parent = Array(0..<positions.count)
var members = Array(repeating: 1, count: positions.count)

func root(of i: Int) -> Int {
	let p = parent[i]
	if parent[i] == i {
		return p
	} else {
		let r = root(of: p)
		parent[i] = r
		return r
	}
}

func connect(_ a: Int, _ b: Int) {
	let ra = root(of: a)
	let rb = root(of: b)
	guard ra != rb else { return }
	parent[ra] = rb
	members[rb] += members[ra]
	members[ra] = 0
}

let part1Count = 1000

measureTime {
	for (source, target, _) in distances.prefix(part1Count) {
		connect(source, target)
	}
	
	print(members.max(count: 3).product())
}

measureTime {
	for (source, target, _) in distances.dropFirst(part1Count) {
		connect(source, target)
		guard members[root(of: source)] != positions.count else {
			print(positions[source].x * positions[target].x)
			break
		}
	}
}
