//
//  Sudoku.swift
//  SudokuLadder
//
//  Created by chuck ha on 1/19/24.
//

struct Cell {

	let box: Int
	let row: Int
	let col: Int
	var value: Int?
	var pencilMarks: [Int] = []
	var centerMarks: [Int] = []

	// TODO: consider adding feature: when you click number and the number is already set, unset the number
	mutating func setValue(value: Int) {
		self.value = value
	}

	mutating func addPencilMark(value: Int) {
		// TODO: do not allow duplicates
		// TODO: sort the list
		self.pencilMarks.append(value)
	}

	mutating func addCenterMark(value: Int) {
		// TODO: do not allow duplicates
		// TODO: sort the list
		self.centerMarks.append(value)
	}
}

struct Sudoku {
	var cells: [[Cell]]
	/// width is the number of cells per row
	let width: Int
	/// height is the number of rows
	let height: Int

	init(cells: [[Cell]]) {
		self.cells = cells
		self.height = cells.count
		self.width = cells[0].count
	}

	init() {
		self.width = 9
		self.height = 9
		var cells: [[Cell]] = []
		for i in 0..<height {
			var row: [Cell] = []
			for j in 0..<width {
				row.append(Cell(box: nineByNineBox(row: i, col: j), row: i, col: j))
			}
			cells.append(row)
		}
		self.cells = cells
	}

	//    mutating func selectCell(row: Int, col: Int) {
	//        cells[row][col].selected = true
	//    }
	//
	//    mutating func unselectAllExcept(cell: Cell) {
	//        for (i, row) in cells.enumerated() {
	//            for (j, _) in row.enumerated(){
	//                cells[i][j].selected = i == cell.row && j == cell.col
	//            }
	//        }
	//    }
	//
	//    func selected() -> [Cell] {
	//        var out: [Cell] = []
	//        // TODO: use a filter / learn predicate
	//        for (i, row) in cells.enumerated() {
	//            for (j, _) in row.enumerated(){
	//                if cells[i][j].selected {
	//                    out.append(cells[i][j])
	//                }
	//            }
	//        }
	//        return out
	//    }
}

func nineByNineBox(row: Int, col: Int) -> Int {
	if col >= 0 && col <= 2 && row >= 0 && row <= 2 {
		return 0
	}
	if col >= 3 && col <= 5 && row >= 0 && row <= 2 {
		return 1
	}
	if col >= 6 && col <= 8 && row >= 0 && row <= 2 {
		return 2
	}
	if col >= 0 && col <= 2 && row >= 3 && row <= 5 {
		return 3
	}
	if col >= 3 && col <= 5 && row >= 3 && row <= 5 {
		return 4
	}
	if col >= 6 && col <= 8 && row >= 3 && row <= 5 {
		return 5
	}
	if col >= 0 && col <= 2 && row >= 6 && row <= 8 {
		return 6
	}
	if col >= 3 && col <= 5 && row >= 6 && row <= 8 {
		return 7
	}
	if col >= 6 && col <= 8 && row >= 6 && row <= 8 {
		return 8
	}
	return -1
}
