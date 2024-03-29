//
//  ContentView.swift
//  SudokuLadder
//
//  Created by chuck ha on 1/17/24.
//

// Borders: The math gets hard if you only do one border instead of all edges of all cells.
// The selection borders must also take this into account, it gets tricky. Consider looking into this if you really have to have fine grained controls over the grid layout look.

import SwiftUI

struct GameConfig {
	var layout: [[String: Int]]
	var constraints: [Constraint]
	func asGridGame() -> GridGame {
		return GridGame(cells: layoutToSudoku(layout),
		                constraints: constraints)
	}
}

// intro to killer cages:
// https://sudokupad.app/u1gswfvw2x
func killerCateIntro() -> GameConfig {
	let layout = [
		c(0, 0, 0), c(0, 1, 0), c(0, 2, 1), c(0, 3, 1),
		c(1, 0, 0), c(1, 1, 0), c(1, 2, 1), c(1, 3, 1),
		c(2, 0, 2), c(2, 1, 2), c(2, 2, 3), c(2, 3, 3),
		c(3, 0, 2), c(3, 1, 2), c(3, 2, 3), c(3, 3, 3),
	]
	let w = 4; let h = 4
	var constraints: [Constraint] = []
	for i in 0 ..< h {
		constraints.append(Constraint(name: "Unique in row \(i)", cells: (0 ..< w).map { x in Point(row: i, col: x) }, display: true, valid: uniqueInRegion))
	}
	for i in 0 ..< w {
		constraints.append(Constraint(name: "Unique in column \(i)", cells: (0 ..< h).map { x in Point(row: x, col: i) }, display: true, valid: uniqueInRegion))
	}
	constraints.append(
		Constraint(name: "killer-cage-1",
		           cells: [Point(row: 0, col: 0), Point(row: 0, col: 1)],
		           valid: KillerCageWithSumConstraint(sum: 5))
	)
	return GameConfig(layout: layout, constraints: constraints)
}

// normal sudoku, easy
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

func dims(_ dic: [[String: Int]]) -> (Int, Int) {
	var height: Int = -9999
	var width: Int = -9999
	for entry in dic {
		for (k, v) in entry {
			if k == "col" {
				if v > width {
					width = v
				}
			}
			if k == "row" {
				if v > height {
					height = v
				}
			}
		}
	}
	return (height + 1, width + 1)
}

func layoutToSudoku(_ dic: [[String: Int]]) -> [[Cell]] {
	let cells = dic.map { entry -> Cell in
		Cell(row: entry["row"]!, col: entry["col"]!, region: entry["box"]!, given: entry["given"])
	}
	let (height, width): (Int, Int) = dims(dic)
	var sudokuCells: [[Cell]] = []
	for _ in 0 ..< width {
		var row: [Cell] = []
		for _ in 0 ..< height {
			row.append(Cell(row: 0, col: 0, region: 0))
		}
		sudokuCells.append(row)
	}
	for cell in cells {
		sudokuCells[cell.row][cell.col] = cell
	}
	return sudokuCells
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
let failedAndSelected = mix(c1: constraintFailedBackgroundColor, c2: selectedBackgroundColor)

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
					.border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
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
		.overlay(
			KillerCageView()
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
	@StateObject private var grid: GridGame = killerCateIntro().asGridGame()
	//    @StateObject private var grid: GridGame = layoutToSudoku(normalSudoku)

	var body: some View {
		VStack {
			GridView()
				.padding([.bottom])
			HStack {
				InputView()
				ControlView(controlMode: $grid.inputMode)
			}
		}
		.sheet(isPresented: $grid.victory, onDismiss: {
			grid.reset()
		}, content: {
			Text("you won!")
		})
		.environmentObject(grid)
	}
}

#Preview {
	ContentView()
}
