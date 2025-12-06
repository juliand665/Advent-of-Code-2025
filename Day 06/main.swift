import AoC_Helpers
import Algorithms

let lines = input().lines()
let numbers = Matrix(lines.dropLast().map { $0.ints() })
let ops = lines.last!
	.split(whereSeparator: \.isWhitespace)
	.map { $0 == "*" ? ((*) as (Int, Int) -> Int) : (+) }

let part1 = zip(numbers.transposed().rows, ops).sum { col, op in
	col.reduce(op)!
}
print(part1)

let actualNumbers = Matrix(lines.dropLast()).transposed().rows
	.lazy
	.map { Int(String($0).trimming(while: \.isWhitespace)) }
	.split(separator: nil)
let part2 = zip(actualNumbers, ops).sum { group, op in
	group.lazy.map { $0! }.reduce(op)!
}
print(part2)
