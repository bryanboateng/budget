import SwiftUI

struct SwiftUIView: View {
	@Environment(\.dismiss) private var dismiss

	let budgets: any Collection<Budget>

	private var balanceAdjustments: [Mase] {
		budgets
			.flatMap({ budget in
				budget.balanceAdjustments.map { adjustment in
					Mase(
						budgetID: budget.id,
						budgetName: budget.name,
						budgetSymbol: budget.symbol,
						budgetColor: budget.color,
						balanceAdjustment: adjustment
					)
				}
			})
			.sorted { lhs, rhs in
				lhs.balanceAdjustment.date > rhs.balanceAdjustment.date
			}
	}

	var body: some View {
		NavigationStack {
			Group {
				if balanceAdjustments.isEmpty {
					ContentUnavailableView("Kein Verlauf", systemImage: "clock")
				} else {
					List(balanceAdjustments, id: \.self) { wef in
						HStack(alignment: .firstTextBaseline) {
							VStack(alignment: .leading) {
								Text(
									"\(Text("●").foregroundStyle(wef.budgetColor.swiftUIColor)) \(Text(wef.budgetName))"
								)
								Text(wef.balanceAdjustment.date, format: .dateTime.day().month().hour().minute().second())
									.foregroundStyle(.secondary)
							}
							Spacer()
							Text(wef.balanceAdjustment.amount, format: .eur().sign(strategy: .accountingAlways()))
								.monospacedDigit()
						}
					}
					.navigationTitle("Verlauf")
					.navigationBarTitleDisplayMode(.inline)
				}
			}
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Fertig") {
						dismiss()
					}
				}
			}
		}
	}
}

private struct Mase: Hashable {
	let budgetID: UUID
	let budgetName: String
	let budgetSymbol: String
	let budgetColor: Budget.Color
	let balanceAdjustment: Budget.BalanceAdjustment
}

#Preview {
	var groceriesBudget = Budget(name: "Groceries", symbol: "carrot", color: .green, monthlyAllocation: 300)
	var rentBudget = Budget(name: "Rent", symbol: "house", color: .red, monthlyAllocation: 800)
	var entertainmentBudget = Budget(name: "Entertainment", symbol: "popcorn", color: .cyan, monthlyAllocation: 100)
	var travelBudget = Budget(name: "Travel", symbol: "globe.europe.africa", color: .blue, monthlyAllocation: 200)

	// Create an array to easily manage all budgets
	var allBudgets = [groceriesBudget, rentBudget, entertainmentBudget, travelBudget]

	// Define specific date adjustments using a DateFormatter
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "yyyy/MM/dd"
	let date1 = dateFormatter.date(from: "2023/09/01")!
	let date2 = dateFormatter.date(from: "2023/09/15")!
	let date3 = dateFormatter.date(from: "2023/09/20")!
	let date4 = dateFormatter.date(from: "2023/09/25")!

	// Create BalanceAdjustment objects
	let adjustment1 = Budget.BalanceAdjustment(date: date1, amount: 50)
	let adjustment2 = Budget.BalanceAdjustment(date: date2, amount: -25)
	let adjustment3 = Budget.BalanceAdjustment(date: date3, amount: 30)
	let adjustment4 = Budget.BalanceAdjustment(date: date4, amount: -10)

	// Add BalanceAdjustment objects to appropriate budgets
	groceriesBudget.balanceAdjustments.insert(adjustment1)
	groceriesBudget.balanceAdjustments.insert(adjustment2)
	entertainmentBudget.balanceAdjustments.insert(adjustment3)
	entertainmentBudget.balanceAdjustments.insert(adjustment4)

	// Create more adjustments using the adjustBalance method
	groceriesBudget.adjustBalance(-15)
	rentBudget.adjustBalance(-800)
	entertainmentBudget.adjustBalance(-5)
	travelBudget.adjustBalance(500)

	// Update the array with the modified budget objects (since Budget is a value type)
	allBudgets[0] = groceriesBudget
	allBudgets[1] = rentBudget
	allBudgets[2] = entertainmentBudget
	allBudgets[3] = travelBudget

	return SwiftUIView(budgets: allBudgets)
}
