//
//  SudokuViewModel.swift
//  SudokuLadder
//
//  Created by chuck ha on 1/20/24.
//

import SwiftUI

let cellWidth: CGFloat = 40
let cellHeight: CGFloat = 40

// class SudokuViewModel: ObservableObject {
////    @Published var board: Sudoku
//    @Published var currentMode: ControlMode = .BigNumber
//    @Published var cells: [[CellViewModel]]
//
//    var sudoku: Sudoku
//
//    init(sudoku: Sudoku) {
//        cells = sudoku.cells.map { (row) -> [CellViewModel] in
//            row.map {(cell) -> CellViewModel in
//                CellViewModel(cell: cell)
//            }
//        }
//    }
//
//    func unselectAllExcept(cell: CellViewModel) {
//        sudoku.unselectAllExcept(cell: cell.cell)
//    }
//
//    func selectCell(rowidx: Int, colidx: Int) {
//        sudoku.selectCell(row: rowidx, col: colidx)
//    }
//
//    func getCell(rowidx: Int, colidx: Int) -> CellViewModel {
//        return cells[rowidx][colidx]
//    }
//
//    func rows() -> [[Cell]] {
//        return board.cells
//    }
//
//    func column(idx: Int) -> [Cell] {
//        return board.cells[idx]
//    }
//
//    func rowCount() -> Int {
//        return board.height
//    }
//
//    func columnCount() -> Int {
//        return board.width
//    }
//
//    func selectCellFromPoint(at point: CGPoint, cw: CGFloat, ch: CGFloat) {
//        let row = Int(point.y / cw)
//        let column = Int(point.x / ch)
//        if row >= 0 && row < board.height && column >= 0 && column < board.width {
//            selectCell(rowidx: row, colidx: column)
//        }
//    }
//
//    func handleNumInput(input: Int) {
//        let selected = board.selected()
//        switch currentMode {
//        case .BigNumber:
//            for cell in selected {
//                board.cells[cell.row][cell.col].setValue(value: input)
//            }
//        case .CornerNumber:
//            for cell in selected {
//                board.cells[cell.row][cell.col].addPencilMark(value: input)
//            }
//        case .MiddleNumber:
//            for cell in selected {
//                board.cells[cell.row][cell.col].addCenterMark(value: input)
//            }
//        }
//    }
// }

// SudokuViewModel is the model that layers UI concerns on top of sudoku.
// What are the UI concerns of sudoku? How big it is? No. Where the borders are? Yes!
class SudokuViewModelV2: ObservableObject {
	private var sudoku: Sudoku
	@Published var cells: [[CellViewModel]]

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
				cells[i][j].selected = false
			}
		}
	}
}

// CellViewModel is the model that layers UI concerns on top of cells.
class CellViewModel: ObservableObject, Hashable {
	let id = UUID()
	private var cell: Cell
	@Published var boxBorder: Edge.Set = []

	@Published var top: Bool = false
	@Published var leading: Bool = false
	@Published var bottom: Bool = false
	@Published var trailing: Bool = false
	@Published var selected: Bool = false

	let selectedColor = Color(red: 0.2, green: 0.2, blue: 0.6, opacity: 0.8)
	let defaultColor = Color(red: 0.8, green: 0.8, blue: 0.8)

	init(cell: Cell) {
		self.cell = cell
	}

	func color() -> Color {
		if selected {
			return selectedColor
		}
		return defaultColor
	}

	func display() -> String {
		cell.value?.description ?? "9"
	}

	func select() {
		selected = true
	}

	func row() -> Int { return cell.row }
	func col() -> Int { return cell.col }
	func box() -> Int { return cell.box }

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
