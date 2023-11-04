import OrderedCollections
import SwiftUI

struct BalanceHistory: View {
	@Environment(\.dismiss)
	private var dismiss

	let budgets: any Collection<Budget>

	private var groupedRows: OrderedDictionary<YearMonth, [Row]> {
		var groupedRows: OrderedDictionary<YearMonth, [Row]> = [:]

		for budget in budgets {
			for balanceAdjustment in budget.balanceAdjustments {
				let dateComponents = Calendar
					.current
					.dateComponents([.month, .year], from: balanceAdjustment.date)
				let yearMonth = YearMonth(
					month: dateComponents.month!,
					year: dateComponents.year!
				)
				groupedRows[yearMonth, default: []].append(
					Row(
						budgetName: budget.name,
						budgetColor: budget.color,
						balanceAdjustment: balanceAdjustment
					)
				)
			}
		}

		for rowGroup in groupedRows {
			groupedRows[rowGroup.key] = rowGroup.value.sorted(by: { lhs, rhs in
				lhs.balanceAdjustment.date > rhs.balanceAdjustment.date
			})
		}

		groupedRows.sort { lhs, rhs in
			lhs.key > rhs.key
		}

		return groupedRows
	}

	var body: some View {
		NavigationStack {
			Group {
				if groupedRows.isEmpty {
					if #available(iOS 17, *) {
						ContentUnavailableView("Kein Verlauf", systemImage: "clock")
					} else {
						Text("Kein Verlauf")
					}
				} else {
					List {
						ForEach(groupedRows.elements, id: \.0) { rowGroup in
							RowGroup(rowGroup: rowGroup)
						}
					}
				}
			}
			.navigationTitle("Verlauf")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Fertig") {
						dismiss()
					}
				}
			}
		}
	}

	private struct RowGroup: View {
		let rowGroup: OrderedDictionary<
			BalanceHistory.YearMonth,
			[BalanceHistory.Row]
		>.Elements.Element

		var body: some View {
			Section(
				Calendar.current
					.date(from: DateComponents(year: rowGroup.0.year, month: rowGroup.0.month))!
					.formatted(.dateTime.year().month(.wide))
			) {
				ForEach(rowGroup.1, id: \.balanceAdjustment) { row in
					HStack(alignment: .firstTextBaseline) {
						VStack(alignment: .leading) {
							HStack{
								Image(systemName: "circlebadge")
									.symbolVariant(.fill)
									.foregroundStyle(row.budgetColor.swiftUIColor)
								Text(row.budgetName)
							}
							Text(
								row.balanceAdjustment.date,
								format: .dateTime.day().month().hour().minute().second()
							)
							.foregroundStyle(.secondary)
						}
						Spacer()
						Text(
							row.balanceAdjustment.amount,
							format: .eur().sign(strategy: .always())
						)
						.monospacedDigit()
					}
				}
			}
		}
	}

	private struct YearMonth: Hashable, Comparable {
		let month: Int
		let year: Int

		func hash(into hasher: inout Hasher) {
			hasher.combine(month)
			hasher.combine(year)
		}

		static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
			if lhs.year == rhs.year {
				return lhs.month < rhs.month
			}
			return lhs.year < rhs.year
		}
	}

	private struct Row {
		let budgetName: String
		let budgetColor: Budget.Color
		let balanceAdjustment: Budget.BalanceAdjustment
	}
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

	return BalanceHistory(budgets: allBudgets)
}
