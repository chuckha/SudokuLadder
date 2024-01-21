//
//  SudokuViewModel.swift
//  SudokuLadder
//
//  Created by chuck ha on 1/20/24.
//

import SwiftUI

class SudokuViewModel: ObservableObject {
    @Published var board: Sudoku
    @Published var currentMode: ControlMode = .BigNumber

    init() {
        board = Sudoku()
    }

    func unselectAllExcept(cell: Cell) {
        board.unselectAllExcept(cell: cell)
    }

    func selectCell(rowidx: Int, colidx: Int) {
        board.selectCell(row: rowidx, col: colidx)
    }

    func getCell(rowidx: Int, colidx: Int) -> Cell {
        return board.cells[rowidx][colidx]
    }

    func rows() -> [[Cell]] {
        return board.cells
    }

    func column(idx: Int) -> [Cell] {
        return board.cells[idx]
    }

    func rowCount() -> Int {
        return board.height
    }

    func columnCount() -> Int {
        return board.width
    }

    func selectCellFromPoint(at point: CGPoint, cw: CGFloat, ch: CGFloat) {
        let row = Int(point.y / cw)
        let column = Int(point.x / ch)
        if row >= 0 && row < board.height && column >= 0 && column < board.width {
            selectCell(rowidx: row, colidx: column)
        }
    }

    func handleNumInput(input: Int) {
        let selected = board.selected()
        switch currentMode {
        case .BigNumber:
            for cell in selected {
                board.cells[cell.row][cell.col].setValue(value: input)
            }
        case .CornerNumber:
            for cell in selected {
                board.cells[cell.row][cell.col].addPencilMark(value: input)
            }
        case .MiddleNumber:
            for cell in selected {
                board.cells[cell.row][cell.col].addCenterMark(value: input)
            }
        }
    }
}

enum ControlMode {
    case BigNumber
    case CornerNumber
    case MiddleNumber
}
