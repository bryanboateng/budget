import Charts
import SwiftUI

struct BudgetDetail: View {
	@EnvironmentObject private var model: Model

	@State private var isEditing = false
	@State private var isAdjustingBalance = false
	@State private var isBeingDeleted = false

	let budget: Budget
	let category: Category

	var body: some View {
		NavigationStack {
			List {
				Section {
					HStack {
						Label {
							Text(budget.name)
								.multilineTextAlignment(.leading)
						} icon: {
							Image(systemName: budget.symbol)
								.font(.title3)
								.foregroundStyle(category.color.swiftUIColor)
						}
					}
				}
				BudgetView(budget: budget)
				Section {
					BalanceAdjustmentList(balanceAdjustments: budget.balanceAdjustments)
				} header: {
					Text("Verlauf")
				}
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Menu {
						Button {
							isEditing = true
						} label: {
							Label("Bearbeiten", systemImage: "pencil")
						}

						Button(role: .destructive) {
							isBeingDeleted = true
						} label: {
							Label("Löschen", systemImage: "trash")
						}
					} label: {
						Text("Bearbeiten")
					}
				}
				ToolbarItemGroup(placement: .bottomBar) {
					Spacer()
					Button("Saldo anpassen", systemImage: "arrow.left.arrow.right") {
						isAdjustingBalance = true
					}
				}
			}
			.navigationTitle(budget.name)
			.navigationBarTitleDisplayMode(.inline)
			.sheet(isPresented: $isEditing) {
				BudgetEditor(budget: budget, category: category)
					.environmentObject(model)
			}
			.sheet(isPresented: $isAdjustingBalance) {
				BalanceAdjuster(budget: budget, category: category)
					.environmentObject(model)
			}
			.actionSheet(isPresented: $isBeingDeleted) {
				ActionSheet(
					title: Text("\(budget.name) löschen"),
					message: Text("Möchtest das Budget \(budget.name) wirklich löschen? Dieser Vorgang kann nicht widerrufen werden."),
					buttons: [
						.destructive(Text("Budget löschen")) {
							model.delete(budget, of: category)
						},
						.cancel()
					]
				)
			}
		}
	}
}

#Preview {
	var budget = Budget(name: "Urlaub", symbol: "globe.europe.africa")
	budget.balanceAdjustments = [
		BalanceAdjustment(date: .now, amount: budget.monthlyAllocation),
		BalanceAdjustment(date: .now.addingTimeInterval(1_000), amount: -10)
	]
	return BudgetDetail(
		budget: budget,
		category: Category(name: "Employee", color: .green)
	)
}

private struct BudgetView: View {
	let budget: Budget

	var body: some View {
		Section {
			HStack {
				Text("Ausgabefähiger Betrag")
					.foregroundStyle(.secondary)
				Spacer()
				Text(budget.spendableBalance, format: .eur())
			}
			HStack {
				Text("Ausgabefähige Tage")
					.foregroundStyle(.secondary)
				Spacer()
				Text(
					"\(budget.spendableDays.formatted(.number.precision(.fractionLength(1)))) d"
				)
			}
		} header: {
			Text("Verfügbar")
		}
		Section {
			Group {
				HStack {
					Text("Aktueller Betrag")
						.foregroundStyle(.secondary)
					Spacer()
					Text(budget.currentBalance, format: .eur())
				}
				HStack {
					Text("Geplanter Betrag")
						.foregroundStyle(.secondary)
					Spacer()
					Text(budget.plannedBalance, format: .eur())
				}
				HStack {
					Text("Monatliche Zuweisung")
						.foregroundStyle(.secondary)
					Spacer()
					Text(budget.monthlyAllocation, format: .eur())
				}
			}
			.monospacedDigit()
		}
	}
}

private struct BalanceAdjustmentList: View {
	let balanceAdjustments: Set<BalanceAdjustment>

	var body: some View {
		if balanceAdjustments.isEmpty {
			ContentUnavailableView {
				Label("Kein Verlauf", systemImage: "clock")
			}
		} else {
			ForEach(balanceAdjustments.sorted { $0.date > $1.date }) { adjustment in
				HStack {
					Text(adjustment.date, format: .dateTime.day().month().hour().minute().second())
						.foregroundStyle(.secondary)
					Spacer()
					Text(adjustment.amount, format: .eur().sign(strategy: .accountingAlways()))
						.monospacedDigit()
				}
			}
		}
	}
}
