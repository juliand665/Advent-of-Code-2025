import AoC_Helpers
import SimpleParser
import Algorithms

func area(from start: Vector2, through end: Vector2) -> Int {
	((end - start).absolute + .init(1, 1)).product // increment by 1 because ranges are inclusive
}

measureTime {
	let redTiles = input().lines().map(Vector2.init)
	let largestArea = redTiles.pairwiseCombinations().lazy.map(area).max()!
	print(largestArea)
	
	// for part 2, compress coordinates to maintain order but get rid of all the space in between
	// then we can make a reasonably sized matrix, flood fill the outside, and check our rect for outside-filled pixels to validate
	
	// technically we should have a .flatMap { [$0 - 1, $0] } in here to ensure there's a gap between each pair for the flood fill to enter, but in practice it's not necessary
	let xs = [0] + redTiles.map(\.x)/*.flatMap { [$0 - 1, $0] }*/.uniqued().sorted()
	let ys = [0] + redTiles.map(\.y)/*.flatMap { [$0 - 1, $0] }*/.uniqued().sorted()
	let xIndices = Dictionary(uniqueKeysWithValues: xs.indexed().lazy.map { ($1, $0) })
	let yIndices = Dictionary(uniqueKeysWithValues: ys.indexed().lazy.map { ($1, $0) })
	let reindexed = redTiles.map { Vector2(xIndices[$0.x]!, yIndices[$0.y]!) }
	
	// draw lines between corner tiles
	var grid = Matrix(width: xs.count + 1, height: ys.count + 1, repeating: 0)
	for (tile1, tile2) in zip(reindexed, reindexed.cycled().dropFirst()) {
		if tile1.x == tile2.x {
			for y in min(tile1.y, tile2.y)...max(tile1.y, tile2.y) {
				grid[tile1.x, y] = 1
			}
		} else if tile1.y == tile2.y {
			for x in min(tile1.x, tile2.x)...max(tile1.x, tile2.x) {
				grid[x, tile1.y] = 1
			}
		} else { fatalError() }
	}
	
	// flood fill from outside
	print("flood filling")
	measureTime {
		var toVisit: Set<Vector2> = [.zero]
		while let next = toVisit.popFirst() {
			grid[next] = 2
			toVisit.formUnion(next.neighbors.lazy.filter { grid.element(at: $0) == 0 })
		}
	}
	//print(grid)
	
	// now we just need to avoid including any 2s in our rects
	func isValidRect(from start: Vector2, through end: Vector2) -> Bool {
		for x in xIndices[min(start.x, end.x)]!...xIndices[max(start.x, end.x)]! {
			for y in yIndices[min(start.y, end.y)]!...yIndices[max(start.y, end.y)]! {
				if grid[x, y] == 2 { return false }
			}
		}
		return true
	}
	
	print("computing largest areas")
	let largestAreas = measureTime {
		redTiles.pairwiseCombinations()
			.lazy
			.filter { $0.x < $1.x } // only consider one of (a, b) and (b, a)
			.map { ($0, $1, area: area(from: $0, through: $1)) }
			.sorted { -$0.area }
	}
	
	print("finding largest valid area")
	let largestValidArea = measureTime {
		largestAreas
			.first { start, end, _ in
				isValidRect(from: start, through: end)
			}!
	}
	
	print(largestValidArea)
}
