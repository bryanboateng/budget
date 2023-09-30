import Charts
import SwiftUI

struct BudgetDetail: View {
	@EnvironmentObject private var model: Model
	@Environment(\.dismiss) private var dismiss

	@State private var isEditing = false
	@State private var isAdjustingBalance = false
	@State private var isBeingDeleted = false

	let budget: Budget

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
								.foregroundStyle(budget.color.swiftUIColor)
						}
					}
				}
				BudgetView(budget: budget)
				Section {
					BalanceAdjustmentList(
						balanceAdjustments: {
							switch budget.strategy {
							case .noMonthlyAllocation(let nwoen):
								nwoen.balanceAdjustments
							case .withMonthlyAllocation(let nwoen):
								nwoen.balanceAdjustments
							}
						}()
					)
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
				BudgetEditor(budget: budget)
					.environmentObject(model)
			}
			.sheet(isPresented: $isAdjustingBalance) {
				BalanceAdjuster(budget: budget)
					.environmentObject(model)
			}
			.actionSheet(isPresented: $isBeingDeleted) {
				ActionSheet(
					title: Text("\(budget.name) löschen"),
					message: Text("Möchtest das Budget \(budget.name) wirklich löschen? Dieser Vorgang kann nicht widerrufen werden."),
					buttons: [
						.destructive(Text("Budget löschen")) {
							model.delete(budget)
							dismiss()
						},
						.cancel()
					]
				)
			}
		}
	}
}

#Preview {
	let budget = Budget(
		name: "Urlaub",
		symbol: "globe.europe.africa",
		color: .green,
		strategy: .withMonthlyAllocation(
			.init(
				balanceAdjustments: [
					BalanceAdjustment(date: .now, amount: 4.5),
					BalanceAdjustment(date: .now.addingTimeInterval(1_000), amount: -10)
				],
				monthlyAllocation: 4.5)
		)
	)
	return BudgetDetail(budget: budget)
}

private struct BudgetView: View {
	let budget: Budget

	var body: some View {
		switch budget.strategy {
		case .withMonthlyAllocation(let moin):
			Section {
				HStack {
					Text("Verfügbares Guthaben")
						.foregroundStyle(.secondary)
					Spacer()
					Text(moin.discretionaryFunds, format: .eur())
				}
				HStack {
					Text("Verfügbare Tage")
						.foregroundStyle(.secondary)
					Spacer()
					Text(
						"\(moin.discretionaryDays.formatted(.number.precision(.fractionLength(1)))) d"
					)
				}
			} header: {
				Text("Verfügbar")
			}
		case .noMonthlyAllocation(_): EmptyView()
		}
		Section {
			Group {
				HStack {
					Text("Aktueller Saldo")
						.foregroundStyle(.secondary)
					Spacer()
					Text(
						{
							switch budget.strategy {
							case .noMonthlyAllocation(let ogvi):
								ogvi.balance
							case .withMonthlyAllocation(let mdonw):
								mdonw.currentBalance
							}
						}(),
						format: .eur()
					)
				}
				switch budget.strategy {
				case .withMonthlyAllocation(let moin):
					HStack {
						Text("Prognostizierter Saldo")
							.foregroundStyle(.secondary)
						Spacer()
						Text(moin.projectedBalance, format: .eur())
					}
					HStack {
						Text("Monatliche Zuweisung")
							.foregroundStyle(.secondary)
						Spacer()
						Text(moin.monthlyAllocation, format: .eur())
					}
				case .noMonthlyAllocation(_): EmptyView()
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
