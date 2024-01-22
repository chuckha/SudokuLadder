//
//  ContentView.swift
//  SudokuLadder
//
//  Created by chuck ha on 1/17/24.
//

import SwiftUI

let normalSudoku: [[String: Int]] = [
	c(0, 0, 0), c(0, 1, 0), c(0, 2, 0), c(0, 3, 1), c(0, 4, 1),
	c(0, 5, 1), c(0, 6, 2), c(0, 7, 2),
	c(0, 8, 2),
	c(1, 0, 0), c(1, 1, 0), c(1, 2, 0), c(1, 3, 1), c(1, 4, 1),
	c(1, 5, 1), c(1, 6, 2), c(1, 7, 2),
	c(1, 8, 2),
	c(2, 0, 0), c(2, 1, 0), c(2, 2, 0), c(2, 3, 1), c(2, 4, 1),
	c(2, 5, 1), c(2, 6, 2), c(2, 7, 2),
	c(2, 8, 2),
	c(3, 0, 3), c(3, 1, 3), c(3, 2, 3), c(3, 3, 4), c(3, 4, 4),
	c(3, 5, 4), c(3, 6, 5), c(3, 7, 5),
	c(3, 8, 5),
	c(4, 0, 3), c(4, 1, 3), c(4, 2, 3), c(4, 3, 4), c(4, 4, 4),
	c(4, 5, 4), c(4, 6, 5), c(4, 7, 5),
	c(4, 8, 5),
	c(5, 0, 3), c(5, 1, 3), c(5, 2, 3), c(5, 3, 4), c(5, 4, 4),
	c(5, 5, 4), c(5, 6, 5), c(5, 7, 5),
	c(5, 8, 5),
	c(6, 0, 6), c(6, 1, 6), c(6, 2, 6), c(6, 3, 7), c(6, 4, 7),
	c(6, 5, 7), c(6, 6, 8), c(6, 7, 8),
	c(6, 8, 8),
	c(7, 0, 6), c(7, 1, 6), c(7, 2, 6), c(7, 3, 7), c(7, 4, 7),
	c(7, 5, 7), c(7, 6, 8), c(7, 7, 8),
	c(7, 8, 8),
	c(8, 0, 6), c(8, 1, 6), c(8, 2, 6), c(8, 3, 7), c(8, 4, 7),
	c(8, 5, 7), c(8, 6, 8), c(8, 7, 8),
	c(8, 8, 8),
]

func c(_ row: Int, _ col: Int, _ box: Int) -> [String: Int] {
	return ["row": row, "col": col, "box": box]
}

func layoutToSuduoku(_ dic: [[String: Int]]) -> Sudoku {
	let cells = dic.map { entry -> Cell in
		Cell(box: entry["box"]!, row: entry["row"]!, col: entry["col"]!)
	}
	var sudokuCells: [[Cell]] = []
	for _ in 0 ..< 9 {
		var row: [Cell] = []
		for _ in 0 ..< 9 {
			row.append(Cell(box: 0, row: 0, col: 0))
		}
		sudokuCells.append(row)
	}
	for cell in cells {
		sudokuCells[cell.row][cell.col] = cell
	}
	return Sudoku(cells: sudokuCells)
}

// - [x] add borders to cells
// - [] constraints (cell constraints, row constraints, column constraints, box constraints, grid constraints, etc)
// - [] edit value
// - [] add middle marks
// - [] controls

struct ContentView: View {
	@StateObject private var sudoku: SudokuViewModelV2 = .init(
		sudoku: layoutToSuduoku(normalSudoku))

	var body: some View {
		VStack {
			Grid(horizontalSpacing: 0, verticalSpacing: 0) {
				ForEach(sudoku.cells, id: \.self) { row in
					GridRow {
						ForEach(row, id: \.self) { cell in
							CellView(cell: cell)
						}
					}
				}
			}
			.gesture(
				DragGesture(minimumDistance: 0)
					.onChanged { value in
						// Will there be a bug if the user drags over the same location during a long drag?
						if value.startLocation == value.location {
							sudoku.clearSelection()
						}
						sudoku.selectCellFromPoint(at: value.location)
					})
			HStack {
				NumpadView(sudoku: sudoku)
				ControlsView(controlMode: $sudoku.currentMode)
			}
		}
	}
}

struct CellView: View {
	@ObservedObject var cell: CellViewModel

	var body: some View {
		ZStack {
			Rectangle()
				.frame(width: cellWidth, height: cellHeight)
				.foregroundColor(cell.defaultColor)
				.overlay(
					EdgeBorder(color: Color.primary, width: 3.0, edges: cell.boxBorder)
						.stroke()
				)
				.overlay(
					EdgeBorder(color: Color.primary, width: 1.0, edges: .all)
						.stroke()
				)
				.overlay(
					EdgeBorder(color: cell.selectedColor, width: 4.0, edges: cell.selectedBorder, offset: 2.0)
						.stroke()
				)
			if cell.display() == "" {
				let (top, bottom) = splitArray(Array(cell.pencilMarks).sorted())
				VStack {
					HStack(spacing: 4) {
						ForEach(top, id: \.self) { num in
							Text(num.description)
								.font(.system(size: 10))
						}
					}
					Spacer()
					HStack(spacing: 1) {
						ForEach(bottom, id: \.self) { num in
							Text(num.description)
								.font(.system(size: 10))
						}
					}
				}
				.frame(width: cellWidth, height: cellHeight)
//				Text("1").font(.system(size: 10))
			} else {
				Text(cell.display())
					.font(.system(size: 30))
			}
		}
	}
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

struct NumpadView: View {
	@ObservedObject var sudoku: SudokuViewModelV2

	var body: some View {
		VStack {
			ForEach(0 ... 2, id: \.self) { i in
				HStack {
					ForEach(0 ... 2, id: \.self) { j in
						let val = i * 3 + j + 1
						Text("\(val)")
							.onTapGesture {
								sudoku.handleNumInput(input: val)
							}
					}
				}
			}
		}
	}
}

struct ControlsView: View {
	@Binding var controlMode: ControlMode

	var body: some View {
		HStack {
			VStack {
				Button(action: {
					controlMode = .BigNumber
				}, label: {
					Text("9")
						.font(.system(size: 32))
				})
				Button(action: {
					controlMode = .CornerNumber
				}, label: {
					VStack {
						HStack {
							Text("1")
							Text("2")
						}
						HStack {
							Text("3")
						}
					}
				})
				Button(action: {
					controlMode = .MiddleNumber
				}, label: {
					HStack {
						Text("1")
						Text("2")
					}
				})
			}
		}
	}
}

// struct BorderStyle {
//    var color: Color = Color.primary
//    var width: CGFloat
// }

#Preview {
	ContentView()
}

struct EdgeBorder: Shape {
	var color: Color
	var width: CGFloat
	var edges: Edge.Set
	var offset: CGFloat = 0

	func path(in rect: CGRect) -> Path {
		var path = Path()
		if edges.contains(.top) {
			path.move(to: CGPoint(x: rect.minX + offset, y: rect.minY + offset))
			path.addLine(to: CGPoint(x: rect.maxX - offset, y: rect.minY + offset))
		}
		if edges.contains(.leading) {
			path.move(to: CGPoint(x: rect.minX + offset, y: rect.minY + offset))
			path.addLine(to: CGPoint(x: rect.minX + offset, y: rect.maxY - offset))
		}
		if edges.contains(.bottom) {
			path.move(to: CGPoint(x: rect.minX + offset, y: rect.maxY - offset))
			path.addLine(to: CGPoint(x: rect.maxX - offset, y: rect.maxY - offset))
		}
		if edges.contains(.trailing) {
			path.move(to: CGPoint(x: rect.maxX - offset, y: rect.minY + offset))
			path.addLine(to: CGPoint(x: rect.maxX - offset, y: rect.maxY - offset))
		}
		return path
	}

	func stroke() -> some View {
		stroke(color, style: StrokeStyle(lineWidth: width))
	}
}
