//
//  KillerCage.swift
//  SudokuLadder
//
//  Created by chuck ha on 1/26/24.
//

import SwiftUI

func KillerCageWithSumConstraint(sum: Int) -> ([Cell]) -> [Cell] {
	return { (region: [Cell]) -> [Cell] in
		var out: Set<Cell> = []
		var realSum: Int = 0
		for cell in region {
			guard cell.effectiveValue() != nil else {
				continue
			}
			// killer cages with sums must sum correctly
			if let val = cell.effectiveValue() {
				realSum += val
			}

			// killer cages cannot repeat
			// TODO: this is twice as much work as it needs to do sheesh
			for cell2 in region {
				guard cell2.effectiveValue() != nil else {
					continue
				}
				if cell.row == cell2.row, cell.col == cell2.col {
					continue
				}
				if cell.effectiveValue()! == cell2.effectiveValue()! {
					out.insert(cell2)
					out.insert(cell)
				}
			}
		}
		if sum != realSum {
			for cell in region {
				if let _ = cell.effectiveValue() {
					out.insert(cell)
				}
			}
		}
		return Array(out)
	}
}

struct KillerCageView: View {
	@EnvironmentObject var grid: GridGame

	var body: some View {
		ForEach(0 ..< grid.width, id: \.self) { _ in
			HStack(spacing: 0) {
				ForEach(0 ..< grid.height, id: \.self) { _ in
					Rectangle()
						.foregroundStyle(.clear)
				}
			}
		}
	}
}
