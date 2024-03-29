import ComposableArchitecture
import SwiftUI

@Reducer
struct BudgetDetailFeature {
	@ObservableState
	struct State {
		var budget: Budget
		@Presents var destination: Destination.State?
	}
	enum Action {
		case balanceOperationButtonTapped
		case cancelEditButtonTapped
		case delegate(Delegate)
		case deleteButtonTapped
		case destination(PresentationAction<Destination.Action>)
		case editButtonTapped
		case saveBudgetButtonTapped
		enum Delegate {
			case deleteStandup(id: Budget.ID)
			case budgetUpdated(Budget)
		}
	}
	@Dependency(\.dismiss) var dismiss

	@Reducer
	enum Destination {
		case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
		case editBudget(BudgetFormFeature)
		enum ConfirmationDialog {
			case confirmDeletion
		}
	}

	var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .balanceOperationButtonTapped:
				return .none
			case .cancelEditButtonTapped:
				state.destination = nil
				return .none
			case .destination(.presented(.confirmationDialog(.confirmDeletion))):
				return .run { [id = state.budget.id] send in
					await send(.delegate(.deleteStandup(id: id)))
					await self.dismiss()
				}
			case .destination:
				return .none
			case .delegate:
				return .none
			case .deleteButtonTapped:
				state.destination = .confirmationDialog(
					ConfirmationDialogState {
						TextState("\(state.budget.name) löschen")
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
				let projection = state.budget.projection
				state.destination = .editBudget(
					BudgetFormFeature.State(
						name: state.budget.name,
						color: state.budget.color,
						projectionIsEnabled: projection != nil,
						monthlyAllocation: projection?.monthlyAllocation ?? 0
					)
				)
				return .none
			case .saveBudgetButtonTapped:
				guard case let .editBudget(budgetForm) = state.destination else { return .none }

				let trimmedName = budgetForm.name.trimmingCharacters(in: .whitespacesAndNewlines)
				guard !trimmedName.isEmpty else { return .none }

				let projectionHasChanged = {
					if let projection = state.budget.projection {
						if budgetForm.projectionIsEnabled {
							return projection.monthlyAllocation != budgetForm.monthlyAllocation
						} else {
							return true
						}
					} else {
						return budgetForm.projectionIsEnabled
					}
				}()
				guard state.budget.name != trimmedName
							|| state.budget.color != budgetForm.color
							|| projectionHasChanged
				else { return .none }

				state.budget.name = trimmedName
				state.budget.color = budgetForm.color
				if budgetForm.projectionIsEnabled {
					state.budget.setMonthlyAllocation(budgetForm.monthlyAllocation)
				} else {
					state.budget.removeMonthlyAllocation()
				}
				state.destination = nil
				return .none
			}
		}
		.ifLet(\.$destination, action: \.destination)
		.onChange(of: \.budget) { oldValue, newBudget in
			Reduce { state, action in
					.send(.delegate(.budgetUpdated(newBudget)))
			}
		}
	}
}
struct BudgetDetailView: View {
	@Bindable var store: StoreOf<BudgetDetailFeature>

	var body: some View {
		List {
			Section {
				CirclebadgeLabel(self.store.budget.name, color: self.store.budget.color)
			}
			BudgetView(budget: self.store.budget)
			Section("Verlauf") {
				BalanceAdjustmentList(
					balanceAdjustments: self.store.budget.balanceAdjustments
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
		.navigationTitle(self.store.budget.name)
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
//		.fullScreenCover(isPresented: $isOperatingOnBalance) {
//			BalanceOperator(primaryBudgetID: budget.id)
//				.environmentObject(model)
//		}
	}
}

#Preview {
	MainActor.assumeIsolated {
		NavigationStack {
			BudgetDetailView(
				store: Store(
					initialState: BudgetDetailFeature.State(
						budget: {
							var budget = Budget(
								id: UUID(),
								name: "Urlaub",
								color: .green
							)
							budget.adjustBalance(4.5)
							budget.balanceAdjustments.insert(
								.init(
									id: UUID(),
									date: .now.addingTimeInterval(1_000),
									amount: -10
								)
							)
							return budget
						}()
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
	let balanceAdjustments: Set<Budget.BalanceAdjustment>

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
