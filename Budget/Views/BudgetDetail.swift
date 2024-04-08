import ComposableArchitecture
import SwiftUI

@Reducer
struct BudgetDetailFeature {
	@ObservableState
	struct State {
		var budgetID: Budget.ID
		@Shared(.fileStorage(.budgets)) var budgets: IdentifiedArrayOf<Budget> = []
		@Presents var destination: Destination.State?
		var budget: Budget? {
			budgets[id: budgetID]
		}
	}
	enum Action {
		case balanceOperationButtonTapped
		case cancelEditButtonTapped
		case deleteButtonTapped
		case destination(PresentationAction<Destination.Action>)
		case editButtonTapped
		case saveBudgetButtonTapped
	}
	@Dependency(\.dismiss) var dismiss

	@Reducer
	enum Destination {
		case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
		case editBudget(BudgetFormFeature)
		case operateBalance(BalanceOperatorFeature)
		enum ConfirmationDialog {
			case confirmDeletion
		}
	}

	var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .balanceOperationButtonTapped:
				state.destination = .operateBalance(
					BalanceOperatorFeature.State(
						primaryBudgetID: state.budgetID
					)
				)
				return .none
			case .cancelEditButtonTapped:
				state.destination = nil
				return .none
			case .destination(.presented(.confirmationDialog(.confirmDeletion))):
				state.budgets.remove(id: state.budgetID)
				return .run { _ in
					await self.dismiss()
				}
			case .destination:
				return .none
			case .deleteButtonTapped:
				guard let budget = state.budget else { return .none}
				state.destination = .confirmationDialog(
					ConfirmationDialogState {
						TextState("\(budget.name) löschen")
					} actions: {
						ButtonState(
							role: .destructive,
							action: .confirmDeletion
						) {
							TextState("Budget löschen")
						}
						ButtonState(role: .cancel) {
							TextState("Abbrechen")
						}
					} message: {
						TextState("Möchtest das Budget wirklich löschen? Dieser Vorgang kann nicht widerrufen werden.")
					}
				)
				return .none
			case .editButtonTapped:
				guard let budget = state.budget else { return .none}
				let projection = budget.projection
				state.destination = .editBudget(
					BudgetFormFeature.State(
						name: budget.name,
						color: budget.color,
						projectionIsEnabled: projection != nil,
						monthlyAllocation: projection?.monthlyAllocation ?? 0
					)
				)
				return .none
			case .saveBudgetButtonTapped:
				guard case let .editBudget(budgetForm) = state.destination,
						var budget = state.budget else { return .none }

				let trimmedName = budgetForm.name.trimmingCharacters(in: .whitespacesAndNewlines)
				guard !trimmedName.isEmpty else { return .none }

				let projectionHasChanged = {
					if let projection = budget.projection {
						if budgetForm.projectionIsEnabled {
							return projection.monthlyAllocation != budgetForm.monthlyAllocation
						} else {
							return true
						}
					} else {
						return budgetForm.projectionIsEnabled
					}
				}()
				guard budget.name != trimmedName
							|| budget.color != budgetForm.color
							|| projectionHasChanged
				else { return .none }

				budget.name = trimmedName
				budget.color = budgetForm.color
				if budgetForm.projectionIsEnabled {
					budget.setMonthlyAllocation(budgetForm.monthlyAllocation)
				} else {
					budget.removeMonthlyAllocation()
				}
				state.budgets[id: budget.id] = budget
				state.destination = nil
				return .none
			}
		}
		.ifLet(\.$destination, action: \.destination)
	}
}
struct BudgetDetailView: View {
	@Bindable var store: StoreOf<BudgetDetailFeature>

	var body: some View {
		if let budget = self.store.budget {
			List {
				Section {
					CirclebadgeLabel(budget.name, color: budget.color)
				}
				BudgetView(budget: budget)
				Section("Verlauf") {
					BalanceAdjustmentList(
						balanceAdjustments: budget.balanceAdjustments
					)
				}
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Menu {
						Button {
							self.store.send(.editButtonTapped)
						} label: {
							Label("Bearbeiten", systemImage: "pencil")
						}
						Button(role: .destructive) {
							self.store.send(.deleteButtonTapped)
						} label: {
							Label("Löschen", systemImage: "trash")
						}
					} label: {
						Text("Bearbeiten")
					}
				}
				ToolbarItemGroup(placement: .bottomBar) {
					Spacer()
					Button("Saldo anpassen", systemImage: "eurosign") {
						self.store.send(.balanceOperationButtonTapped)
					}
					.symbolVariant(.circle)
				}
			}
			.navigationTitle(budget.name)
			.navigationBarTitleDisplayMode(.inline)
			.sheet(
				item: self.$store.scope(
					state: \.destination?.editBudget,
					action: \.destination.editBudget
				)
			) { store in
				NavigationStack {
					BudgetFormView(store: store)
						.navigationTitle("Budget bearbeiten")
						.navigationBarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .cancellationAction) {
								Button("Abbrechen") {
									self.store.send(.cancelEditButtonTapped)
								}
							}
							ToolbarItem(placement: .confirmationAction) {
								Button("Fertig") {
									self.store.send(.saveBudgetButtonTapped)
								}
							}
						}
				}
			}
			.confirmationDialog(
				self.$store.scope(
					state: \.destination?.confirmationDialog,
					action: \.destination.confirmationDialog
				)
			)
			.fullScreenCover(
				item: self.$store.scope(
					state: \.destination?.operateBalance,
					action: \.destination.operateBalance
				)
			) { store in
				BalanceOperatorView(store: store)
			}
		} else {
			EmptyView()
		}
	}
}

#Preview {
	let budget = {
		var budget = Budget(
			id: UUID(),
			name: "Urlaub",
			color: .green
		)
		budget.adjustBalance(4.5)
		budget.balanceAdjustments.append(
			.init(
				id: UUID(),
				date: .now.addingTimeInterval(1_000),
				amount: -10
			)
		)
		return budget
	}()
	return MainActor.assumeIsolated {
		NavigationStack {
			BudgetDetailView(
				store: Store(
					initialState: BudgetDetailFeature.State(
						budgetID: budget.id,
						budgets: [budget]
					)
				) {
					BudgetDetailFeature()
				}
			)
		}
	}
}

private struct BudgetView: View {
	let budget: Budget

	var body: some View {
		if let projection = budget.projection {
			Section("Verfügbar") {
				Text("Verfügbares Guthaben")
					.foregroundStyle(.secondary)
					.badge(
						Text(projection.discretionaryFunds, format: .eur())
					)
				Text("Verfügbare Tage")
					.foregroundStyle(.secondary)
					.badge(
						Text(
							"\(projection.discretionaryDays.formatted(.number.precision(.fractionLength(1)))) d"
						)
					)
			}
		}
		Section {
			Group {
				Text("Aktueller Saldo")
					.foregroundStyle(.secondary)
					.badge(
						Text(budget.balance, format: .eur())
					)
				if let projection = budget.projection {
					Text("Prognostizierter Saldo")
						.foregroundStyle(.secondary)
						.badge(
							Text(projection.projectedBalance, format: .eur())
						)
					Text("Monatliche Zuweisung")
						.foregroundStyle(.secondary)
						.badge(
							Text(projection.monthlyAllocation, format: .eur())
						)
				}
			}
			.monospacedDigit()
		}
	}
}

private struct BalanceAdjustmentList: View {
	let balanceAdjustments: IdentifiedArrayOf<Budget.BalanceAdjustment>

	var body: some View {
		if balanceAdjustments.isEmpty {
			ContentUnavailableView {
				Label("Kein Verlauf", systemImage: "clock")
			}
		} else {
			ForEach(balanceAdjustments.sorted { $0.date > $1.date }) { adjustment in
				Text(adjustment.date, format: .dateTime.day().month().hour().minute().second())
					.foregroundStyle(.secondary)
					.badge(
						Text(adjustment.amount, format: .eur().sign(strategy: .always()))
							.monospacedDigit()
							.foregroundStyle(adjustment.amount > 0 ? .green : .primary)
					)
			}
		}
	}
}
