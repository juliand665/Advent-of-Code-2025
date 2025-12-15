import AoC_Helpers
import Algorithms

// thought i was being clever, turns out part 2 went a completely different direction
struct BitSet {
	var rawValue: Int
	var capacity: Int
	
	var count: Int {
		rawValue.nonzeroBitCount
	}
	
	var isEmpty: Bool {
		rawValue == 0
	}
	
	var members: [Int] {
		(0..<capacity).filter { self[$0] }
	}
	
	subscript(i: Int) -> Bool {
		get {
			(rawValue >> i) & 1 == 1
		}
		set {
			if newValue {
				rawValue |= 1 << i
			} else {
				rawValue &= ~(1 << i)
			}
		}
	}
	
	init(rawValue: Int, capacity: Int) {
		self.rawValue = rawValue
		self.capacity = capacity
	}
	
	init(isOn: [Bool]) {
		self.rawValue = isOn.reversed().reduce(0) { $0 << 1 | ($1 ? 1 : 0) }
		self.capacity = isOn.count
	}
	
	init(members: [Int], capacity: Int) {
		self.rawValue = 0
		for member in members {
			rawValue |= 1 << member
		}
		self.capacity = capacity
	}
	
	func intersection(with other: Self) -> Self {
		assert(capacity == other.capacity)
		return Self(rawValue: rawValue & other.rawValue, capacity: capacity)
	}
	
	func subtracting(_ other: Self) -> Self {
		assert(capacity == other.capacity)
		return Self(rawValue: rawValue & ~other.rawValue, capacity: capacity)
	}
}

extension MutableCollection where Element: AdditiveArithmetic {
	func adding(_ offset: Element, at indices: some Sequence<Index>) -> Self {
		guard offset != .zero else { return self }
		return indices.reduce(into: self) { $0[$1] += offset }
	}
}

#if DEBUG
let isPrinting = true
#else
let isPrinting = false
#endif

struct Machine {
	var targetState: BitSet
	var buttons: [[Int]]
	var joltages: [Int]
	
	init(string: Substring) {
		let (_, rawIndicators, rawButtons, rawJoltages) = string.wholeMatch(of: /\[(.+)\] (.+) \{(.+)\}/)!.output
		targetState = BitSet(isOn: rawIndicators.map { $0 == "#" })
		buttons = rawButtons.split(separator: " ").map { $0.ints() }
		joltages = rawJoltages.ints()
	}
	
	func minPressesForIndicators() -> Int {
		let buttons = buttons.map { BitSet(members: $0, capacity: joltages.count) }
		
		let options = (0..<(1 << buttons.count)).map { BitSet(rawValue: $0, capacity: joltages.count) }
		let valid = options.filter { option in
			let state = buttons.enumerated().lazy.filter { option[$0.offset] }.map(\.element.rawValue).reduce(0, ^)
			return state == targetState.rawValue
		}
		let minPresses = valid.lazy.map(\.rawValue.nonzeroBitCount).min()!
		return minPresses
	}
	
	func minPressesForJoltage() -> Int {
		// TODO: the process will be effectively the same for the same "order" between the remaining joltages, e.g. `1, 3` will involve the same buttons as `2, 5` albeit with different press counts. i feel like we can combine that somehow
		// actually, is that true?? for something like AB BC CA A B C, 4/4/4 will have very different presses from 3/3/3
		
		print()
		print(self)
		
		let affectingButtons = joltages.indices.map { j in
			BitSet(members: buttons.enumerated().lazy.filter { $1.contains(j) }.map(\.offset), capacity: buttons.count)
		}
		
		func minPresses(joltages: [Int], buttons: BitSet) -> Int? {
			let indent: String
			if isPrinting {
				indent = String(repeatElement("\t", count: self.buttons.count - buttons.count))
				print("\(indent)solving \(joltages) with \(buttons.members)")
			} else {
				indent = ""
			}
			
			let j = joltages.indices.lazy
				.filter { joltages[$0] > 0 }
				.map { j in (j, affectingButtons[j].intersection(with: buttons)) }
				.min { $0.1.count < $1.1.count }
			
			guard let (j, availableButtons) = j else { return 0 }
			if isPrinting {
				print("\(indent)options affecting j=\(j): \(availableButtons.members)")
			}
			
			guard !availableButtons.isEmpty else { return nil }
			let buttons = buttons.subtracting(availableButtons)
			
			if isPrinting {
				print("\(indent)remaining: \(buttons.members)")
			}
			
			func explore(joltages: [Int], buttonIndices: ArraySlice<Int>) -> Int? {
				guard let b = buttonIndices.first else { fatalError() }
				let nextIndices = buttonIndices.dropFirst()
				let button = self.buttons[b]
				
				if isPrinting {
					print("\(indent)exploring \(joltages) with \(self.buttons[b])")
				}
				
				guard !nextIndices.isEmpty else {
					// have to use this one fully to make it
					let presses = joltages[j]
					let joltages = joltages.adding(-presses, at: button)
					guard joltages.allSatisfy({ $0 >= 0 }) else { return nil }
					if joltages.allSatisfy({ $0 == 0 }) {
						return presses
					} else if let answer = minPresses(joltages: joltages, buttons: buttons) {
						return presses + answer
					} else {
						return nil
					}
				}
				
				var buttons = buttons
				buttons[b] = false
				let maxPresses = button.lazy.map { joltages[$0] }.min()!
				return (0...maxPresses).lazy.compactMap { presses in
					let joltages = joltages.adding(-presses, at: button)
					if isPrinting {
						print("\(indent)pressing \(button) \(presses)x")
					}
					guard let answer = explore(joltages: joltages, buttonIndices: nextIndices) else { return nil }
					return answer + presses
				}.min()
			}
			
			return explore(joltages: joltages, buttonIndices: availableButtons.members[...])
		}
		
		return minPresses(joltages: joltages, buttons: BitSet(members: Array(buttons.indices), capacity: buttons.count))!
	}
}

extension Sequence {
	func powerSet() -> [[Element]] {
		guard let (first, rest) = chop() else { return [[]] }
		return rest.powerSet().flatMap { [$0, [first] + $0]  }
	}
}

let machines = input().lines().map(Machine.init)
print(machines.map { $0.minPressesForIndicators() }.sum())

var total = 0
for machine in machines {
	measureTime {
		let minPresses = machine.minPressesForJoltage()
		total += minPresses
		print(minPresses)
	}
}
print("grand total: \(total)")
