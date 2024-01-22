//
//  SudokuViewModel.swift
//  SudokuLadder
//
//  Created by chuck ha on 1/20/24.
//

import SwiftUI

let cellWidth: CGFloat = 40
let cellHeight: CGFloat = 40

// SudokuViewModel is the model that layers UI concerns on top of sudoku.
// What are the UI concerns of sudoku? How big it is? No. Where the borders are? Yes!
class SudokuViewModelV2: ObservableObject {
	private var sudoku: Sudoku
	@Published var cells: [[CellViewModel]]
	@Published var currentMode: ControlMode = .BigNumber

	init(sudoku: Sudoku) {
		self.sudoku = sudoku
		cells = sudoku.cells.map { row -> [CellViewModel] in
			row.map { cell -> CellViewModel in
				CellViewModel(cell: cell)
			}
		}
		// box border gets calculated once
		// for each cell, look at all neighbors,
		// if the neighbor is in the same box, do not set the border
		// if the neighbor is not in the same box, add a border
		// if the value is outside the bounds, add a border
		for row in cells {
			for cell in row {
				var top = false
				var leading = false
				var bottom = false
				var trailing = false
				// top
				if cell.row() > 0 {
					if cells[cell.row() - 1][cell.col()].box() != cell.box() {
						top = true
					}
				}
				if cell.row() == 0 {
					top = true
				}
				// trailing
				if cell.col() < self.sudoku.width - 1 {
					if cells[cell.row()][cell.col() + 1].box() != cell.box() {
						trailing = true
					}
				}
				if cell.col() == self.sudoku.width - 1 {
					trailing = true
				}
				// bottom
				if cell.row() < self.sudoku.height - 1 {
					if cells[cell.row() + 1][cell.col()].box() != cell.box() {
						bottom = true
					}
				}
				if cell.row() == self.sudoku.height - 1 {
					bottom = true
				}
				// leading
				if cell.col() > 0 {
					if cells[cell.row()][cell.col() - 1].box() != cell.box() {
						leading = true
					}
				}
				if cell.col() == 0 {
					leading = true
				}

				cell.setBoxBorder(top: top, leading: leading, bottom: bottom, trailing: trailing)
			}
		}
	}

	convenience init() {
		self.init(sudoku: Sudoku())
	}

	func selectCell(rowidx: Int, colidx: Int) {
		cells[rowidx][colidx].select()
		var top = true
		var leading = true
		var bottom = true
		var trailing = true
		// top
		if rowidx > 0 {
			if cells[rowidx - 1][colidx].selected {
				top = false
				cells[rowidx - 1][colidx].removeSelectionBorder(edge: .bottom)
			}
		}
		// leading
		if colidx > 0 {
			if cells[rowidx][colidx - 1].selected {
				leading = false
				cells[rowidx][colidx - 1].removeSelectionBorder(edge: .trailing)
			}
		}
		// bottom
		if rowidx < sudoku.height - 1 {
			if cells[rowidx + 1][colidx].selected {
				bottom = false
				cells[rowidx + 1][colidx].removeSelectionBorder(edge: .top)
			}
		}
		// trailing
		if colidx < sudoku.width - 1 {
			if cells[rowidx][colidx + 1].selected {
				trailing = false
				cells[rowidx][colidx + 1].removeSelectionBorder(edge: .leading)
			}
		}
		cells[rowidx][colidx].setSelectionBorder(top: top, leading: leading, bottom: bottom, trailing: trailing)
	}

	func selectCellFromPoint(at point: CGPoint) {
		let row = Int(point.y / cellWidth)
		let column = Int(point.x / cellHeight)
		if row >= 0 && row < sudoku.height && column >= 0 && column < sudoku.width {
			selectCell(rowidx: row, colidx: column)
		}
	}

	func clearSelection() {
		for (i, cellRow) in cells.enumerated() {
			for (j, _) in cellRow.enumerated() {
				cells[i][j].unselect()
			}
		}
	}

	func selected() -> [CellViewModel] {
		var out: [CellViewModel] = []
		for (i, cellRow) in cells.enumerated() {
			for (j, _) in cellRow.enumerated() {
				if cells[i][j].selected {
					out.append(cells[i][j])
				}
			}
		}
		return out
	}

	func handleNumInput(input: Int) {
		let selected = selected()
		switch currentMode {
		case .BigNumber:
			for cell in selected {
				cells[cell.row()][cell.col()].setValue(value: input)
			}
		case .CornerNumber:
			for cell in selected {
				cells[cell.row()][cell.col()].addPencilMark(value: input)
			}
		case .MiddleNumber:
			for cell in selected {
				cells[cell.row()][cell.col()].addCenterMark(value: input)
			}
		}
	}
}

// CellViewModel is the model that layers UI concerns on top of cells.
class CellViewModel: ObservableObject, Hashable {
	let id = UUID()
	@Published var cell: Cell
	@Published var boxBorder: Edge.Set = []
	@Published var selectedBorder: Edge.Set = []
	@Published var selected: Bool = false
	@Published var pencilMarks: Set<Int> = Set()
	@Published var centerMarks: Set<Int> = Set()

	let selectedColor = Color(red: 0.2, green: 0.2, blue: 0.6, opacity: 0.8)
	let defaultColor = Color(red: 0.8, green: 0.8, blue: 0.8)

	init(cell: Cell) {
		self.cell = cell
	}

	func unselect() {
		selectedBorder = []
		selected = false
	}

	func color() -> Color {
		if selected {
			return selectedColor
		}
		return defaultColor
	}

	func display() -> String {
		cell.value?.description ?? ""
	}

	func select() {
		selected = true
	}

	// TODO: consider adding feature: when you click number and the number is already set, unset the
	func setValue(value: Int) {
		cell.setValue(value: value)
	}

	func addPencilMark(value: Int) {
		pencilMarks.insert(value)
	}

	func addCenterMark(value: Int) {
		centerMarks.insert(value)
	}

	func row() -> Int { return cell.row }
	func col() -> Int { return cell.col }
	func box() -> Int { return cell.box }

	func removeSelectionBorder(edge: Edge.Set) {
		selectedBorder.remove(edge)
	}

	// TODO: set trailing and bottom on all; then set top on the top row and leading on the leading column
	func setSelectionBorder(top: Bool = false, leading: Bool = false, bottom: Bool = false, trailing: Bool = false) {
		if top {
			selectedBorder.insert(.top)
		}
		if leading {
			selectedBorder.insert(.leading)
		}
		if bottom {
			selectedBorder.insert(.bottom)
		}
		if trailing {
			selectedBorder.insert(.trailing)
		}
	}

	func setBoxBorder(
		top: Bool = false, leading: Bool = false, bottom: Bool = false, trailing: Bool = false
	) {
		if top {
			boxBorder.insert(.top)
		}
		if leading {
			boxBorder.insert(.leading)
		}
		if bottom {
			boxBorder.insert(.bottom)
		}
		if trailing {
			boxBorder.insert(.trailing)
		}
	}

	// Equatable
	static func == (lhs: CellViewModel, rhs: CellViewModel) -> Bool {
		return lhs.id == rhs.id
	}

	// Hashable
	func hash(into hasher: inout Hasher) {
		hasher.combine(cell.row)
		hasher.combine(cell.col)
	}
}

enum ControlMode {
	case BigNumber
	case CornerNumber
	case MiddleNumber
}
