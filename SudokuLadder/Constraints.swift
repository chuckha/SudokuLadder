//
//  Constraints.swift
//  SudokuLadder
//
//  Created by chuck ha on 1/24/24.
//

import Foundation

protocol ConstraintName {
	var name: String { get }
}

struct Constraint {
	let name: String
	let group: [Cell]
}

protocol RowConstraint: ConstraintName {
	func valid(cell: Cell, row: [Cell]) -> Bool
}

protocol ColumnConstraint: ConstraintName {
	func valid(cell: Cell, col: [Cell]) -> Bool
}

protocol RegionConstraint: ConstraintName {
	func valid(cell: Cell, region: [Cell]) -> Bool
}

protocol CustomConstraint: ConstraintName {
	func valid(cell: Cell, region: [Cell]) -> bool
}

struct UniqueInRow: RowConstraint {
	var name: String = "UniqueInRow"
	func valid(cell: Cell, row: [Cell]) -> Bool {
		for c in row {
			if c.col == cell.col {
				continue
			}
			if c.effectiveValue() == cell.effectiveValue() {
				return false
			}
		}
		return true
	}
}

struct UniqueInColumn: ColumnConstraint {
	var name: String = "UniqueInColumn"
	func valid(cell: Cell, col: [Cell]) -> Bool {
		for c in col {
			if c.row == cell.row {
				continue
			}
			if c.effectiveValue() == cell.effectiveValue() {
				return false
			}
		}
		return true
	}
}

struct UniqueInRegion: RegionConstraint {
	var name: String = "UniqueInRegion"
	func valid(cell: Cell, region: [Cell]) -> Bool {
		for c in region {
			if c.row == cell.row && c.col == cell.col {
				continue
			}
			if c.effectiveValue() == cell.effectiveValue() {
				return false
			}
		}
		return true
	}
}

struct KillerCage: CustomConstraint {
	var name: String = "KillerCage"
}
