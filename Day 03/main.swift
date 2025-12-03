import AoC_Helpers

let banks = input().lines().map { $0.map { Int(String($0))! } }

func maxJolts(from bank: some Collection<Int>, count: Int, current: Int = 0) -> Int {
	let available = bank.dropLast(count - 1)
	// we can just greedily take the first occurrence of the highest joltage that leaves enough space for count - 1 more batteries
	let bestIndex = available.firstIndex(of: available.max()!)!
	let current = current * 10 + bank[bestIndex]
	guard count > 1 else { return current }
	let remaining = bank.suffix(from: bestIndex).dropFirst()
	return maxJolts(from: remaining, count: count - 1, current: current)
}

print(banks.sum { maxJolts(from: $0, count: 2) })
print(banks.sum { maxJolts(from: $0, count: 12) })
