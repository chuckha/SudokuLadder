//
//  GameLogic.swift
//  SudokuLadder
//
//  Created by chuck ha on 1/27/24.
//

import SwiftUI

struct UserSettings {
	var constraintDisplayRegexes: [Regex<Any>]

	init(constraints: [String]) {
		constraintDisplayRegexes = []
		do {
			constraintDisplayRegexes = try constraints.map { c in try Regex(c) }
		} catch {
			print("failed to make a regex from \(constraints)")
		}
	}
}

struct Cell: Hashable {
	var row: Int
	var col: Int
	var region: Int = 0
	var value: Int? = nil
	var given: Int? = nil
	var selected: Bool = false
	var regionBorders: [Edge] = []
	var edgeBorders: [Edge] = []
	var pencilMarks: Set<Int> = []
	var centerMarks: Set<Int> = []
	var failedConstraints: Set<String> = []

	func effectiveValue() -> Int? {
		return given ?? value
	}

	func displayValue() -> String {
		return given?.description ?? value?.description ?? ""
	}

	// foregroundColor is more like background color
	func foregroundColor() -> Color {
		if failedConstraints.count > 0 && selected {
			return failedAndSelected
		}
		if failedConstraints.count > 0 {
			return constraintFailedBackgroundColor
		}
		if selected {
			return selectedBackgroundColor
		}
		return Color.clear
	}

	// displayColor is text
	func displayColor() -> Color {
		if given != nil {
			return givenColor
		}
		return inputColor
	}

	mutating func setValue(val: Int?) {
		value = val
	}

	mutating func addPencilMark(val: Int) {
		pencilMarks.insert(val)
	}

	mutating func addCenterMark(val: Int) {
		centerMarks.insert(val)
	}

	mutating func clearValue() {
		value = nil
	}

	mutating func clearCenterMarks() {
		centerMarks = Set()
	}

	mutating func clearPencilMarks() {
		pencilMarks = Set()
	}

	// Hashable protocol
	func hash(into hasher: inout Hasher) {
		hasher.combine(row)
		hasher.combine(col)
	}
}

func mix(c1: Color, c2: Color) -> Color {
	var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
	var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
	let one = UIColor(c1)
	let two = UIColor(c2)
	one.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
	two.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
	return Color(red: (r1 + r2) / 2.0, green: (g1 + g2) / 2, blue: (b1 + b2) / 2)
}

class GridGame: ObservableObject {
	@Published var cells: [[Cell]]
	let height: Int
	let width: Int
	var selected: Set<Cell> = Set()
	@Published var inputMode: ControlMode = .BigNumber
	var constraints: [Constraint] = []
	@Published var victory: Bool = false

	init(cells: [[Cell]], constraints: [Constraint] = []) {
		// TODO: guard against empty cells
		self.cells = cells
		height = cells.count
		width = cells[0].count
		setStaticBorders()
		self.constraints = constraints
	}

	func reset() {
		for (i, row) in cells.enumerated() {
			for (j, _) in row.enumerated() {
				cells[i][j].clearValue()
				cells[i][j].clearCenterMarks()
				cells[i][j].clearPencilMarks()
			}
		}
	}

	func selectCell(_ rowidx: Int, _ colidx: Int) {
		cells[rowidx][colidx].selected = true
		selected.insert(cells[rowidx][colidx])
	}

	func clearSelection() {
		for c in selected {
			cells[c.row][c.col].selected = false
		}
		selected = Set()
	}

	func setCellValue(row: Int, col: Int, value: Int?) {
		guard cells[row][col].given == nil else {
			return
		}
		cells[row][col].setValue(val: value)
		if value == nil {
			cells[row][col].failedConstraints = Set()
			return
		}
		for constraint in constraints {
			for row in cells {
				for cell in row {
					cells[cell.row][cell.col].failedConstraints.remove(constraint.name)
				}
			}
			let activeCells = cellsFromPoints(points: constraint.cells)
			let failedCells = constraint.valid(activeCells)
			for cell in failedCells {
				cells[cell.row][cell.col].failedConstraints.insert(constraint.name)
			}
		}
		checkVictory()
	}

	func cellsFromPoints(points: [Point]) -> [Cell] {
		var out: [Cell] = []
		for row in cells {
			for cell in row {
				for point in points {
					if point.row == cell.row && point.col == cell.col {
						out.append(cell)
					}
				}
			}
		}
		return out
	}

	func checkVictory() {
		for row in cells {
			for cell in row {
				if cell.effectiveValue() == nil {
					return
				}
				if cell.failedConstraints.count > 0 {
					return
				}
			}
		}
		victory = true
	}

	func addPencilMark(row: Int, col: Int, value: Int) {
		guard cells[row][col].given == nil else {
			return
		}
		cells[row][col].addPencilMark(val: value)
	}

	func addCenterMark(row: Int, col: Int, value: Int) {
		guard cells[row][col].given == nil else {
			return
		}
		cells[row][col].addCenterMark(val: value)
	}

	func handleInput(input: Int) {
		switch inputMode {
		case .BigNumber:
			for cell in selected {
				setCellValue(row: cell.row, col: cell.col, value: input)
			}
		case .CornerNumber:
			for cell in selected {
				addPencilMark(row: cell.row, col: cell.col, value: input)
			}
		case .MiddleNumber:
			for cell in selected {
				addCenterMark(row: cell.row, col: cell.col, value: input)
			}
		}
	}

	func handleDelete() {
		switch inputMode {
		case .BigNumber:
			for cell in selected {
				if cells[cell.row][cell.col].value != nil {
					setCellValue(row: cell.row, col: cell.col, value: nil)
					continue
				}
				if cells[cell.row][cell.col].centerMarks.count > 0 {
					cells[cell.row][cell.col].clearCenterMarks()
					continue
				}
				if cells[cell.row][cell.col].pencilMarks.count > 0 {
					cells[cell.row][cell.col].clearPencilMarks()
					continue
				}
			}
		case .CornerNumber:
			for cell in selected {
				if cells[cell.row][cell.col].pencilMarks.count > 0 {
					cells[cell.row][cell.col].clearPencilMarks()
					continue
				}
				if cells[cell.row][cell.col].value != nil {
					setCellValue(row: cell.row, col: cell.col, value: nil)
					continue
				}
				if cells[cell.row][cell.col].centerMarks.count > 0 {
					cells[cell.row][cell.col].clearCenterMarks()
					continue
				}
			}
		case .MiddleNumber:
			for cell in selected {
				if cells[cell.row][cell.col].centerMarks.count > 0 {
					cells[cell.row][cell.col].clearCenterMarks()
					continue
				}
				if cells[cell.row][cell.col].value != nil {
					setCellValue(row: cell.row, col: cell.col, value: nil)
					continue
				}
				if cells[cell.row][cell.col].pencilMarks.count > 0 {
					cells[cell.row][cell.col].clearPencilMarks()
					continue
				}
			}
		}
	}

	private func setStaticBorders() {
		for (i, row) in cells.enumerated() {
			for (j, cell) in row.enumerated() {
				if i == 0 {
					cells[i][j].edgeBorders.append(.top)
				}
				if i > 0 && cells[i - 1][j].region != cell.region {
					cells[i][j].regionBorders.append(.top)
				}
				if i == height - 1 {
					cells[i][j].edgeBorders.append(.bottom)
				}
				if i < height - 1 && cells[i + 1][j].region != cell.region {
					cells[i][j].regionBorders.append(.bottom)
				}
				if j == 0 {
					cells[i][j].edgeBorders.append(.leading)
				}
				if j > 0 && cells[i][j - 1].region != cell.region {
					cells[i][j].regionBorders.append(.leading)
				}
				if j == width - 1 {
					cells[i][j].edgeBorders.append(.trailing)
				}
				if j < width - 1 && cells[i][j + 1].region != cell.region {
					cells[i][j].regionBorders.append(.trailing)
				}
			}
		}
	}
}
