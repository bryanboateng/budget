//import Charts
//import SwiftUI
//
//struct BudgetDetail: View {
//	@EnvironmentObject private var model: Model
//	@Environment(\.dismiss)
//	private var dismiss
//
//	@State private var isEditing = false
//	@State private var isOperatingOnBalance = false
//	@State private var isBeingDeleted = false
//
//	let budget: Budget
//
//	var body: some View {
//		NavigationStack {
//			List {
//				Section {
//					HStack {
//						Label {
//							Text(budget.name)
//								.multilineTextAlignment(.leading)
//						} icon: {
//							Image(systemName: budget.symbol)
//								.foregroundStyle(budget.color.swiftUIColor)
//						}
//					}
//				}
//				BudgetView(budget: budget)
//				Section("Verlauf") {
//					BalanceAdjustmentList(
//						balanceAdjustments: budget.balanceAdjustments
//					)
//				}
//			}
//			.toolbar {
//				ToolbarItem(placement: .navigationBarTrailing) {
//					Menu {
//						Button {
//							isEditing = true
//						} label: {
//							Label("Bearbeiten", systemImage: "pencil")
//						}
//
//						Button(role: .destructive) {
//							isBeingDeleted = true
//						} label: {
//							Label("Löschen", systemImage: "trash")
//						}
//					} label: {
//						Text("Bearbeiten")
//					}
//				}
//				ToolbarItemGroup(placement: .bottomBar) {
//					Spacer()
//					Button("Saldo anpassen", systemImage: "eurosign") {
//						isOperatingOnBalance = true
//					}
//					.symbolVariant(.circle)
//				}
//			}
//			.navigationTitle(budget.name)
//			.navigationBarTitleDisplayMode(.inline)
//			.sheet(isPresented: $isEditing) {
//				BudgetEditor(budget: budget)
//					.environmentObject(model)
//			}
//			.fullScreenCover(isPresented: $isOperatingOnBalance) {
//				BalanceOperator(primaryBudgetID: budget.id)
//					.environmentObject(model)
//			}
//			.actionSheet(isPresented: $isBeingDeleted) {
//				ActionSheet(
//					title: Text("\(budget.name) löschen"),
//					message: Text("Möchtest das Budget \(budget.name) wirklich löschen? Dieser Vorgang kann nicht widerrufen werden."),
//					buttons: [
//						.destructive(Text("Budget löschen")) {
//							model.delete(budget: budget.id)
//							dismiss()
//						},
//						.cancel()
//					]
//				)
//			}
//		}
//	}
//}
//
//#Preview {
//	var budget = Budget(
//		name: "Urlaub",
//		symbol: "globe.europe.africa",
//		color: .green
//	)
//	budget.adjustBalance(4.5)
//	budget.balanceAdjustments.insert(
//		.init(
//			date: .now.addingTimeInterval(1_000),
//			amount: -10
//		)
//	)
//	return BudgetDetail(budget: budget)
//}
//
//private struct BudgetView: View {
//	let budget: Budget
//
//	var body: some View {
//		if let projection = budget.projection {
//			Section("Verfügbar") {
//				HStack {
//					Text("Verfügbares Guthaben")
//						.foregroundStyle(.secondary)
//					Spacer()
//					Text(projection.discretionaryFunds, format: .eur())
//				}
//				HStack {
//					Text("Verfügbare Tage")
//						.foregroundStyle(.secondary)
//					Spacer()
//					Text(
//						"\(projection.discretionaryDays.formatted(.number.precision(.fractionLength(1)))) d"
//					)
//				}
//			}
//		}
//		Section {
//			Group {
//				HStack {
//					Text("Aktueller Saldo")
//						.foregroundStyle(.secondary)
//					Spacer()
//					Text(budget.balance, format: .eur())
//				}
//				if let projection = budget.projection {
//					HStack {
//						Text("Prognostizierter Saldo")
//							.foregroundStyle(.secondary)
//						Spacer()
//						Text(projection.projectedBalance, format: .eur())
//					}
//					HStack {
//						Text("Monatliche Zuweisung")
//							.foregroundStyle(.secondary)
//						Spacer()
//						Text(projection.monthlyAllocation, format: .eur())
//					}
//				}
//			}
//			.monospacedDigit()
//		}
//	}
//}
//
//private struct BalanceAdjustmentList: View {
//	let balanceAdjustments: Set<Budget.BalanceAdjustment>
//
//	var body: some View {
//		if balanceAdjustments.isEmpty {
//			ContentUnavailableView {
//				Label("Kein Verlauf", systemImage: "clock")
//			}
//		} else {
//			ForEach(balanceAdjustments.sorted { $0.date > $1.date }) { adjustment in
//				HStack {
//					Text(adjustment.date, format: .dateTime.day().month().hour().minute().second())
//						.foregroundStyle(.secondary)
//					Spacer()
//					Text(adjustment.amount, format: .eur().sign(strategy: .always()))
//						.monospacedDigit()
//						.foregroundStyle(adjustment.amount > 0 ? .green : .primary)
//				}
//			}
//		}
//	}
//}
