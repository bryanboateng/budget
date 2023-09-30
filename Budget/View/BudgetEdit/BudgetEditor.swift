import SwiftUI

struct BudgetEditor: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	let budget: Budget

	@State private var name: String
	@State private var symbol: String
	@State private var showGreeting: Bool
	@State private var grenze: Decimal
	@State private var color: Budget.Color

	private var strategyHasChanged: Bool {
		switch budget.strategy {
		case .noMonthlyAllocation(_):
			return showGreeting
		case .withMonthlyAllocation(let allocatedFinance):
			if showGreeting {
				return allocatedFinance.monthlyAllocation != grenze
			} else {
				return true
			}
		}
	}
	private var changesArePresent: Bool {
		budget.name != name || budget.symbol != symbol || budget.color != color || strategyHasChanged
	}
	func bieoinsen() -> Budget.Change.Oewo? {
		switch budget.strategy {
		case .noMonthlyAllocation(_):
			if showGreeting {
				return .activate(grenze)
			} else {
				return nil
			}
		case .withMonthlyAllocation(let allocatedFinance):
			if showGreeting {
				if allocatedFinance.monthlyAllocation != grenze {
					return .activate(grenze)
				} else {
					return nil
				}
			} else {
				return .deactivate
			}
		}
	}

	var body: some View {
		NavigationStack {
			BudgetCanvas(
				name: $name,
				symbol: $symbol,
				showGreeting: $showGreeting,
				grenze: $grenze,
				color: $color
			)
			.navigationTitle("Budget bearbeiten")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Abbrechen") {
							dismiss()
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Fertig") {
							let newName = name.trimmingCharacters(in: .whitespacesAndNewlines)
							let newSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
							model.update(
								budget: budget.id,
								change: .init(
									name: newName != budget.name ? newName : nil,
									symbol: newSymbol != budget.symbol ? newSymbol : nil,
									color: color != budget.color ? color : nil,
									monthlyAllocation: bieoinsen()
								)
							)
							dismiss()
						}
						.disabled(
							name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
							symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
							!changesArePresent
						)
					}
				}
		}
	}

	init(budget: Budget) {
		self.budget = budget

		_name = State(initialValue: budget.name)
		_symbol = State(initialValue: budget.symbol)
		_color = State(initialValue: budget.color)

		switch budget.strategy {
		case .noMonthlyAllocation:
			_showGreeting = State(initialValue: false)
			_grenze = State(initialValue: 0)
		case .withMonthlyAllocation(let mdonw):
			_showGreeting = State(initialValue: true)
			_grenze = State(initialValue: mdonw.monthlyAllocation)
		}
	}
}
