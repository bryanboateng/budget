import ComposableArchitecture
import SwiftUI

@Reducer
struct BudgetDetailFeature {
	@ObservableState
	struct State {
		var budget: Budget
		@Presents var destination: Destination.State?

		init(budget: Budget, destination: Destination.State? = nil) {
			self.budget = budget
			self.destination = destination
		}
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
	struct Destination {
		@ObservableState
		enum State {
			case confirmationDialog(ConfirmationDialogState<Action.ConfirmationDialog>)
			case editBudget(BudgetFormFeature.State)
		}
		enum Action {
			case confirmationDialog(ConfirmationDialog)
			case editBudget(BudgetFormFeature.Action)
			enum ConfirmationDialog {
				case confirmDeletion
			}
		}
		var body: some ReducerOf<Self> {
			Scope(
				state: \.editBudget,
				action: \.editBudget
			) {
				BudgetFormFeature()
			}
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
						symbol: state.budget.symbol,
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
				guard UIImage(systemName: budgetForm.symbol) != nil else { return .none }

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
							|| state.budget.symbol != budgetForm.symbol
							|| state.budget.color != budgetForm.color
							|| projectionHasChanged
				else { return .none }

				state.budget.name = trimmedName
				state.budget.symbol = budgetForm.symbol
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
		.ifLet(\.$destination, action: \.destination) {
			Destination()
		}
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
				HStack {
					Label {
						Text(self.store.budget.name)
							.multilineTextAlignment(.leading)
					} icon: {
						Image(systemName: self.store.budget.symbol)
							.foregroundStyle(self.store.budget.color.swiftUIColor)
					}
				}
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
								symbol: "globe.europe.africa",
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
				HStack {
					Text("Verfügbares Guthaben")
						.foregroundStyle(.secondary)
					Spacer()
					Text(projection.discretionaryFunds, format: .eur())
				}
				HStack {
					Text("Verfügbare Tage")
						.foregroundStyle(.secondary)
					Spacer()
					Text(
						"\(projection.discretionaryDays.formatted(.number.precision(.fractionLength(1)))) d"
					)
				}
			}
		}
		Section {
			Group {
				HStack {
					Text("Aktueller Saldo")
						.foregroundStyle(.secondary)
					Spacer()
					Text(budget.balance, format: .eur())
				}
				if let projection = budget.projection {
					HStack {
						Text("Prognostizierter Saldo")
							.foregroundStyle(.secondary)
						Spacer()
						Text(projection.projectedBalance, format: .eur())
					}
					HStack {
						Text("Monatliche Zuweisung")
							.foregroundStyle(.secondary)
						Spacer()
						Text(projection.monthlyAllocation, format: .eur())
					}
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
				HStack {
					Text(adjustment.date, format: .dateTime.day().month().hour().minute().second())
						.foregroundStyle(.secondary)
					Spacer()
					Text(adjustment.amount, format: .eur().sign(strategy: .always()))
						.monospacedDigit()
						.foregroundStyle(adjustment.amount > 0 ? .green : .primary)
				}
			}
		}
	}
}
