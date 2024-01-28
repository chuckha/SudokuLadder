//
//  Constraints.swift
//  SudokuLadder
//
//  Created by chuck ha on 1/24/24.
//

struct Point {
	let row: Int
	let col: Int
}

class Constraint {
	let name: String
	var cells: [Point] = []
	var valid: ([Cell]) -> [Cell]
	let display: Bool

	init(name: String, cells: [Point], display: Bool = false, valid: @escaping ([Cell]) -> [Cell]) {
		self.name = name
		self.cells = cells
		self.valid = valid
		self.display = display
	}
}
