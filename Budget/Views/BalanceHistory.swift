import OrderedCollections
import SwiftUI

struct BalanceHistory: View {
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
		Group {
			if groupedRows.isEmpty {
				ContentUnavailableView("Kein Verlauf", systemImage: "clock")
			} else {
				List {
					ForEach(groupedRows.elements, id: \.0) { rowGroup in
						RowGroup(rowGroup: rowGroup)
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
							CirclebadgeLabel(row.budgetName, color: row.budgetColor)
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
						.foregroundStyle(row.balanceAdjustment.amount > 0 ? .green : .primary)
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
	var groceriesBudget = Budget(
		id: UUID(),
		name: "Groceries",
		color: .green,
		monthlyAllocation: 300
	)
	var rentBudget = Budget(
		id: UUID(),
		name: "Rent",
		color: .red,
		monthlyAllocation: 800
	)
	var entertainmentBudget = Budget(
		id: UUID(),
		name: "Entertainment",
		color: .cyan,
		monthlyAllocation: 100
	)
	var travelBudget = Budget(
		id: UUID(),
		name: "Travel",
		color: .blue,
		monthlyAllocation: 200
	)

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
	let adjustment1 = Budget.BalanceAdjustment(id: UUID(), date: date1, amount: 50)
	let adjustment2 = Budget.BalanceAdjustment(id: UUID(), date: date2, amount: -25)
	let adjustment3 = Budget.BalanceAdjustment(id: UUID(), date: date3, amount: 30)
	let adjustment4 = Budget.BalanceAdjustment(id: UUID(), date: date4, amount: -10)

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
