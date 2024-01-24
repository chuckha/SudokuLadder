//
//  ContentView.swift
//  SudokuLadder
//
//  Created by chuck ha on 1/17/24.
//

// Borders: The math gets hard if you only do one border instead of all edges of all cells.
// The selection borders must also take this into account, it gets tricky. Consider looking into this if you really have to have fine grained controls over the grid layout look.

import SwiftUI

//
let normalSudoku: [[String: Int]] = [
	c(0, 0, 0, 9), c(0, 1, 0, 2), c(0, 2, 0, 6), c(0, 3, 1), c(0, 4, 1, 4),
	c(0, 5, 1), c(0, 6, 2), c(0, 7, 2, 8),
	c(0, 8, 2),
	c(1, 0, 0, 4), c(1, 1, 0), c(1, 2, 0), c(1, 3, 1), c(1, 4, 1),
	c(1, 5, 1, 1), c(1, 6, 2), c(1, 7, 2),
	c(1, 8, 2),
	c(2, 0, 0, 8), c(2, 1, 0, 5), c(2, 2, 0), c(2, 3, 1), c(2, 4, 1, 2),
	c(2, 5, 1, 6), c(2, 6, 2, 4), c(2, 7, 2),
	c(2, 8, 2, 9),
	c(3, 0, 3), c(3, 1, 3, 9), c(3, 2, 3, 7), c(3, 3, 4), c(3, 4, 4),
	c(3, 5, 4, 4), c(3, 6, 5), c(3, 7, 5, 6),
	c(3, 8, 5, 3),
	c(4, 0, 3, 3), c(4, 1, 3), c(4, 2, 3, 2), c(4, 3, 4), c(4, 4, 4),
	c(4, 5, 4), c(4, 6, 5, 1), c(4, 7, 5),
	c(4, 8, 5),
	c(5, 0, 3, 5), c(5, 1, 3), c(5, 2, 3), c(5, 3, 4), c(5, 4, 4, 1),
	c(5, 5, 4, 3), c(5, 6, 5), c(5, 7, 5, 4),
	c(5, 8, 5),
	c(6, 0, 6), c(6, 1, 6), c(6, 2, 6), c(6, 3, 7), c(6, 4, 7, 7),
	c(6, 5, 7, 9), c(6, 6, 8, 3), c(6, 7, 8, 1),
	c(6, 8, 8),
	c(7, 0, 6, 7), c(7, 1, 6), c(7, 2, 6, 4), c(7, 3, 7), c(7, 4, 7),
	c(7, 5, 7), c(7, 6, 8), c(7, 7, 8, 5),
	c(7, 8, 8, 8),
	c(8, 0, 6, 2), c(8, 1, 6), c(8, 2, 6), c(8, 3, 7, 5), c(8, 4, 7, 3),
	c(8, 5, 7, 8), c(8, 6, 8, 6), c(8, 7, 8),
	c(8, 8, 8),
]
//
//
//
func c(_ row: Int, _ col: Int, _ box: Int, _ given: Int? = nil) -> [String: Int] {
	var basic = ["row": row, "col": col, "box": box]
	if let g = given {
		basic["given"] = g
	}
	return basic
}

func layoutToSuduoku(_ dic: [[String: Int]]) -> GridGame {
	let cells = dic.map { entry -> Cell in
		Cell(row: entry["row"]!, col: entry["col"]!, region: entry["box"]!, given: entry["given"])
	}
	var sudokuCells: [[Cell]] = []
	for _ in 0 ..< 9 {
		var row: [Cell] = []
		for _ in 0 ..< 9 {
			row.append(Cell(row: 0, col: 0, region: 0))
		}
		sudokuCells.append(row)
	}
	for cell in cells {
		sudokuCells[cell.row][cell.col] = cell
	}
	return GridGame(cells: sudokuCells)
}

func splitArray<T>(_ array: [T]) -> ([T], [T]) {
	if array.count < 4 {
		return (array, [])
	} else {
		let firstHalf = Array(array.prefix(4))
		let secondHalf = Array(array.dropFirst(4))
		return (firstHalf, secondHalf)
	}
}

let cellWidth: CGFloat = 40
let cellHeight: CGFloat = 40
let givenColor = Color.primary
let inputColor = Color(red: 0.3, green: 0.3, blue: 0.9)
let constraintFailedBackgroundColor = Color(red: 0.9, green: 0.7, blue: 0.7)
let selectedBackgroundColor = Color(red: 0.2, green: 0.2, blue: 0.8, opacity: 0.3)

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

struct EdgeBorder: Shape {
	var width: CGFloat
	var edges: [Edge]

	func path(in rect: CGRect) -> Path {
		edges.map { edge -> Path in
			switch edge {
			case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
			case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
			case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
			case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
			}
		}.reduce(into: Path()) { $0.addPath($1) }
	}
}

extension View {
	func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
		overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
	}
}

protocol ConstraintName {
	var name: String { get }
}

protocol RowConstraint: ConstraintName {
	func valid(cell: Cell, row: [Cell]) -> Bool
}

protocol ColumnConstraint: ConstraintName {
	func valid(cell: Cell, col: [Cell]) -> Bool
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

class GridGame: ObservableObject {
	@Published var cells: [[Cell]]
	let height: Int
	let width: Int
	var selected: Set<Cell> = Set()
	@Published var inputMode: ControlMode = .BigNumber
	let rowConstraints: [RowConstraint] = [UniqueInRow()]
	let columnConstraints: [ColumnConstraint] = [UniqueInColumn()]
	let regionConstraints: [String] = []
	let customConstraints: [String] = []

	init(cells: [[Cell]]) {
		// TODO: guard against empty cells
		self.cells = cells
		height = cells.count
		width = cells[0].count
		setStaticBorders()
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
		for rowc in rowConstraints {
			if !rowc.valid(cell: cells[row][col], row: cells[row]) {
				cells[row][col].failedConstraints.insert(rowc.name)
				continue
			}
			cells[row][col].failedConstraints.remove(rowc.name)
		}
		var column: [Cell] = []
		for (i, row) in cells.enumerated() {
			for (j, cell) in row.enumerated() {
				guard j == col else {
					continue
				}
				column.append(cell)
			}
		}
		for colc in columnConstraints {
			if !colc.valid(cell: cells[row][col], col: column) {
				cells[row][col].failedConstraints.insert(colc.name)
				continue
			}
			cells[row][col].failedConstraints.remove(colc.name)
		}
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

struct CellView: View {
	@Binding var cell: Cell

	var body: some View {
		Rectangle()
			.foregroundColor(Color.clear)
			.frame(width: cellWidth, height: cellHeight)
			.overlay(
				Rectangle()
					.stroke(Color.primary, lineWidth: 1)
			)
			.overlay(
				Rectangle()
					.foregroundColor(cell.foregroundColor())
			)
			.overlay(cell.displayValue() != "" ?
				GivenNumber(text: cell.displayValue(), style: cell.displayColor()) : nil
			)
			.overlay(cell.displayValue() == "" ? PencilMarks(marks: Array(cell.pencilMarks), color: cell.displayColor()) : nil)
			.overlay(cell.displayValue() == "" ? MiddleMarks(marks: Array(cell.centerMarks), color: cell.displayColor()) : nil)
			.border(width: 1.5, edges: cell.regionBorders, color: Color.primary)
			.border(width: 3, edges: cell.edgeBorders, color: Color.primary)
	}
}

struct GivenNumber: View {
	let text: String
	var style: Color = .black
	var size: CGFloat = 30

	var body: some View {
		Text(text)
			.font(.system(size: size))
			.foregroundStyle(style)
	}
}

struct PencilMarks: View {
	let marks: [Int]
	var color: Color = .black
	var size: CGFloat = 10

	var body: some View {
		let (top, bottom) = splitArray(marks.sorted())
		VStack {
			HStack(spacing: 4) {
				ForEach(top, id: \.self) { num in
					Text(num.description)
						.font(.system(size: size))
						.foregroundStyle(color)
				}
			}
			Spacer()
			HStack(spacing: 1) {
				ForEach(bottom, id: \.self) { num in
					Text(num.description)
						.font(.system(size: size))
						.foregroundStyle(color)
				}
			}
		}
	}
}

struct MiddleMarks: View {
	let marks: [Int]
	var color: Color = .black
	var size: CGFloat = 7

	var body: some View {
		HStack(spacing: 0) {
			ForEach(marks.sorted(), id: \.self) { num in
				Text(num.description)
					.font(.system(size: size))
					.foregroundStyle(color)
			}
		}
	}
}

struct GridView: View {
	@EnvironmentObject var grid: GridGame

	var body: some View {
		VStack(spacing: 0) {
			ForEach(0 ..< grid.width, id: \.self) { rowidx in
				HStack(spacing: 0) {
					ForEach(0 ..< grid.height, id: \.self) { colidx in
						CellView(cell: $grid.cells[rowidx][colidx])
					}
				}
			}
		}
		.gesture(
			DragGesture(minimumDistance: 0)
				.onChanged { value in
					if value.startLocation == value.location {
						grid.clearSelection()
					}
					selectCellFromPoint(at: value.location)
				}
		)
	}

	func selectCellFromPoint(at point: CGPoint) {
		let row = Int(point.y / cellWidth)
		let column = Int(point.x / cellHeight)
		if row >= 0 && row < grid.height && column >= 0 && column < grid.width {
			grid.selectCell(row, column)
		}
	}
}

struct InputButton: View {
	var label: String
	var action: () -> Void = {}
	var width: CGFloat = 40
	var height: CGFloat = 40

	var body: some View {
		Button(action: action) {
			Color.clear
				.overlay(
					RoundedRectangle(cornerRadius: 0)
						.stroke(Color.accentColor))
				.overlay(Text(label))
		}
		.frame(width: width, height: height)
	}
}

struct InputView: View {
	@EnvironmentObject var grid: GridGame

	var body: some View {
		VStack {
			ForEach(0 ..< 3, id: \.self) { row in
				HStack {
					ForEach(0 ..< 3, id: \.self) { col in
						InputButton(label: (row * 3 + col + 1).description, action: {
							grid.handleInput(input: row * 3 + col + 1)
						})
					}
				}
			}
			HStack {
				InputButton(label: "0", action: {
					grid.handleInput(input: 0)
				})
				InputButton(label: "DELETE", action: {
					grid.handleDelete()
				}, width: 90)
			}
		}
	}
}

struct ControlView: View {
	@Binding var controlMode: ControlMode

	var body: some View {
		VStack {
			Toggle("", isOn: toggleBinding(for: .BigNumber))
				.toggleStyle(ControlToggleStyle())
				.overlay(
					GivenNumber(text: "9", size: 45)
				)
			Toggle("", isOn: toggleBinding(for: .CornerNumber))
				.toggleStyle(ControlToggleStyle())
				.overlay(
					PencilMarks(marks: [1, 2, 3, 4, 5, 6, 7, 8, 9], size: 15)
				)
			Toggle("", isOn: toggleBinding(for: .MiddleNumber))
				.toggleStyle(ControlToggleStyle())
				.overlay(
					MiddleMarks(marks: [1, 2, 3, 4], size: 15)
				)
		}.frame(width: 80)
	}

	func toggleBinding(for mode: ControlMode) -> Binding<Bool> {
		Binding<Bool>(
			get: { mode == controlMode },
			set: { _ in controlMode = mode }
		)
	}
}

struct ControlToggleStyle: ToggleStyle {
	func makeBody(configuration: Configuration) -> some View {
		Button {
			configuration.isOn.toggle()
		} label: {
			Rectangle()
				.frame(width: 60, height: 60)
				.foregroundColor(configuration.isOn ? Color(red: 0.8, green: 0.8, blue: 1) : .clear)
				.border(Color.accentColor, width: 2)
		}
	}
}

enum ControlMode: String, Equatable, CaseIterable {
	case BigNumber
	case CornerNumber
	case MiddleNumber
}

struct ContentView: View {
	@StateObject private var grid: GridGame = layoutToSuduoku(normalSudoku)

	var body: some View {
		VStack {
			GridView()
				.padding([.bottom])
			HStack {
				InputView()
				ControlView(controlMode: $grid.inputMode)
			}
		}
		.environmentObject(grid)
	}
}

#Preview {
	ContentView()
}
