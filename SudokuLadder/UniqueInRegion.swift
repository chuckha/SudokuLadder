//
//  UniqueInRegion.swift
//  SudokuLadder
//
//  Created by chuck ha on 1/27/24.
//

func uniqueInRegion(group: [Cell]) -> [Cell] {
	var out: Set<Cell> = []
	for cell in group {
		for c in group {
			if c.col == cell.col, c.row == cell.row {
				continue
			}
			guard c.effectiveValue() != nil else {
				continue
			}
			guard cell.effectiveValue() != nil else {
				continue
			}
			if c.effectiveValue() == cell.effectiveValue() {
				out.insert(cell)
				out.insert(c)
			}
		}
	}
	return Array(out)
}
