import AoC_Helpers

var grid = Matrix(input().lines()).map { $0 == "@" }
func exposedPositions() -> some Collection<Vector2> {
	grid.positions.filter { pos in
		grid[pos] && pos.neighborsWithDiagonals.count { grid.element(at: $0) == true } < 4
	}
}
print(exposedPositions().count)

var removed = 0
while true {
	let exposed = exposedPositions()
	guard !exposed.isEmpty else { break }
	for pos in exposed {
		grid[pos] = false
	}
	removed += exposed.count
}
print(removed)
