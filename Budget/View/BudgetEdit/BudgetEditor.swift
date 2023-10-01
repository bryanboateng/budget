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
		if let projection = budget.projection {
			if showGreeting {
				return projection.monthlyAllocation != grenze
			} else {
				return true
			}
		} else {
			return showGreeting
		}
	}
	private var changesArePresent: Bool {
		budget.name != name || budget.symbol != symbol || budget.color != color || strategyHasChanged
	}
	func bieoinsen() -> Budget.Change.Oewo? {
		if let projection = budget.projection {
			if showGreeting {
				if projection.monthlyAllocation != grenze {
					return .activate(grenze)
				} else {
					return nil
				}
			} else {
				return .deactivate
			}
		} else {
			if showGreeting {
				return .activate(grenze)
			} else {
				return nil
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

		if let projection = budget.projection {
			_showGreeting = State(initialValue: true)
			_grenze = State(initialValue: projection.monthlyAllocation)
		} else {
			_showGreeting = State(initialValue: false)
			_grenze = State(initialValue: 0)
		}
	}
}
