import AoC_Helpers

let (freshRanges, ids) = input().lineGroups().splat { rawFreshRanges, rawIDs in
	(rawFreshRanges.map { $0.ints().splat(...) }.sorted(on: \.lowerBound), rawIDs.map { Int(String($0))! })
}
print(ids.count { id in freshRanges.contains { $0.contains(id) } })

let deoverlapped: [ClosedRange<Int>] = freshRanges.reduce(into: []) { ranges, range in
	if let prev = ranges.last, prev.contains(range.lowerBound) {
		ranges[ranges.count - 1] = prev.lowerBound...max(prev.upperBound, range.upperBound)
	} else {
		ranges.append(range)
	}
}
print(deoverlapped.sum(of: \.count))
