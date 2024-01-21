//
//  ContentView.swift
//  SudokuLadder
//
//  Created by chuck ha on 1/17/24.
//

import SwiftUI

// - [] add borders to cells
// - [] constraints (cell constraints, row constraints, column constraints, box constraints, grid constraints, etc)
// - [] edit value


struct ContentView: View {
    @StateObject private var viewModel = SudokuViewModel()

    let selectedColor = Color(red: 0, green: 0, blue: 0.8, opacity: 0.8)
    let defaultColor = Color(red: 0.8, green: 0.8, blue: 0.8)
    let cellWidth : CGFloat = 40
    let cellHeight : CGFloat = 40

    var body: some View {
        VStack{
            Grid(horizontalSpacing: 0,verticalSpacing: 0) {
                ForEach(viewModel.rows(), id: \.self) { row in
                    GridRow{
                        ForEach(row, id: \.self) { cell in
                            ZStack{
                                Rectangle()
                                    .frame(width: cellWidth, height: cellHeight)
                                    .foregroundColor(cell.selected ? selectedColor : defaultColor)
                                Text(cell.displayValue())
                            }.onTapGesture {
                                viewModel.unselectAllExcept(cell: cell)
                            }
                        }
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { value in
                        viewModel.selectCellFromPoint(at: value.location, cw: cellWidth, ch: cellHeight)
                    }
            )
            HStack{
                NumpadView(viewModel: viewModel)
                ControlsView(controlMode: $viewModel.currentMode)
            }
        }
    }
}

struct NumpadView: View {
    @ObservedObject var viewModel: SudokuViewModel

    var body: some View {
        VStack{
            ForEach(0...2, id: \.self) { i in
                HStack{
                    ForEach(0...2, id: \.self) { j in
                        let val = i*3+j+1
                        Text("\(val)")
                            .onTapGesture {
                                viewModel.handleNumInput(input: val)
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
        HStack{
            VStack{
                Button("Big") {
                    controlMode = .BigNumber
                }
                Button("Corner") {
                    controlMode = .CornerNumber
                }
                Button("Middle") {
                    controlMode = .MiddleNumber
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
