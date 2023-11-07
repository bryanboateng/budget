//import SwiftUI
//
//struct BudgetEditor: View {
//	@Environment(\.dismiss)
//	private var dismiss
//	@EnvironmentObject private var model: Model
//
//	let budget: Budget
//
//	@State private var name: String
//	@State private var symbol: String
//	@State private var color: Budget.Color
//	@State private var projectionIsEnabled: Bool
//	@State private var monthlyAllocation: Decimal
//
//	private var changesArePresent: Bool {
//		budget.name != name || budget.symbol != symbol || budget.color != color || projectionHasChanged
//	}
//
//	private var projectionHasChanged: Bool {
//		if let projection = budget.projection {
//			if projectionIsEnabled {
//				return projection.monthlyAllocation != monthlyAllocation
//			} else {
//				return true
//			}
//		} else {
//			return projectionIsEnabled
//		}
//	}
//
//	private var projectionChange: Budget.Change.Projection? {
//		if let projection = budget.projection {
//			if projectionIsEnabled {
//				if projection.monthlyAllocation != monthlyAllocation {
//					return .activate(monthlyAllocation)
//				} else {
//					return nil
//				}
//			} else {
//				return .deactivate
//			}
//		} else {
//			if projectionIsEnabled {
//				return .activate(monthlyAllocation)
//			} else {
//				return nil
//			}
//		}
//	}
//
//	var body: some View {
//		NavigationStack {
//			BudgetCanvas(
//				name: $name,
//				symbol: $symbol,
//				color: $color,
//				projectionIsEnabled: $projectionIsEnabled,
//				monthlyAllocation: $monthlyAllocation
//			)
//			.navigationTitle("Budget bearbeiten")
//				.navigationBarTitleDisplayMode(.inline)
//				.toolbar {
//					ToolbarItem(placement: .cancellationAction) {
//						Button("Abbrechen") {
//							dismiss()
//						}
//					}
//					ToolbarItem(placement: .confirmationAction) {
//						Button("Fertig") {
//							let newName = name.trimmingCharacters(in: .whitespacesAndNewlines)
//							let newSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
//							model.update(
//								budget: budget.id,
//								change: .init(
//									name: newName != budget.name ? newName : nil,
//									symbol: newSymbol != budget.symbol ? newSymbol : nil,
//									color: color != budget.color ? color : nil,
//									projection: projectionChange
//								)
//							)
//							dismiss()
//						}
//						.disabled(
//							name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
//							symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
//							!changesArePresent
//						)
//					}
//				}
//		}
//	}
//
//	init(budget: Budget) {
//		self.budget = budget
//
//		_name = State(initialValue: budget.name)
//		_symbol = State(initialValue: budget.symbol)
//		_color = State(initialValue: budget.color)
//
//		if let projection = budget.projection {
//			_projectionIsEnabled = State(initialValue: true)
//			_monthlyAllocation = State(initialValue: projection.monthlyAllocation)
//		} else {
//			_projectionIsEnabled = State(initialValue: false)
//			_monthlyAllocation = State(initialValue: 0)
//		}
//	}
//}
