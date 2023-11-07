import ComposableArchitecture
import SwiftUI

struct BudgetDetailFeature: Reducer {
	struct State: Equatable {
		@PresentationState var editBudget: BudgetFormFeature.State?
		var budget: Budget
	}
	enum Action {
		case balanceOperationButtonTapped
		case editButtonTapped
		case deleteButtonTapped
		case editBudget(PresentationAction<BudgetFormFeature.Action>)
		case cancelEditButtonTapped
		case saveBudgetButtonTapped
	}
	var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .balanceOperationButtonTapped:
				return .none
			case .editButtonTapped:
				let projection = state.budget.projection
				state.editBudget = BudgetFormFeature.State(
					name: state.budget.name,
					symbol: state.budget.symbol,
					color: state.budget.color,
					projectionIsEnabled: projection != nil,
					monthlyAllocation: projection?.monthlyAllocation ?? 0
				)
				return .none
			case .deleteButtonTapped:
				return .none
			case .editBudget:
				return .none
			case .cancelEditButtonTapped:
				state.editBudget = nil
				return .none
			case .saveBudgetButtonTapped:
				guard let editBudget = state.editBudget else { return .none }

				let trimmedName = editBudget.name.trimmingCharacters(in: .whitespacesAndNewlines)
				guard !trimmedName.isEmpty else { return .none }
				guard UIImage(systemName: editBudget.symbol) != nil else { return .none }

				let projectionHasChanged = {
					if let projection = state.budget.projection {
						if editBudget.projectionIsEnabled {
							return projection.monthlyAllocation != editBudget.monthlyAllocation
						} else {
							return true
						}
					} else {
						return editBudget.projectionIsEnabled
					}
				}()
				guard state.budget.name != trimmedName
							|| state.budget.symbol != editBudget.symbol
							|| state.budget.color != editBudget.color
							|| projectionHasChanged
				else { return .none }

				state.budget.name = trimmedName
				state.budget.symbol = editBudget.symbol
				state.budget.color = editBudget.color
				if editBudget.projectionIsEnabled {
					state.budget.setMonthlyAllocation(editBudget.monthlyAllocation)
				} else {
					state.budget.removeMonthlyAllocation()
				}
				state.editBudget = nil
				return .none
			}
		}
		.ifLet(\.$editBudget, action: /Action.editBudget) {
			BudgetFormFeature()
		}
	}
}
struct BudgetDetailView: View {
	let store: StoreOf<BudgetDetailFeature>

	var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			NavigationStack {
				List {
					Section {
						HStack {
							Label {
								Text(viewStore.budget.name)
									.multilineTextAlignment(.leading)
							} icon: {
								Image(systemName: viewStore.budget.symbol)
									.foregroundStyle(viewStore.budget.color.swiftUIColor)
							}
						}
					}
					BudgetView(budget: viewStore.budget)
					Section("Verlauf") {
						BalanceAdjustmentList(
							balanceAdjustments: viewStore.budget.balanceAdjustments
						)
					}
				}
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						Menu {
							Button {
								viewStore.send(.editButtonTapped)
							} label: {
								Label("Bearbeiten", systemImage: "pencil")
							}
							Button(role: .destructive) {
								viewStore.send(.deleteButtonTapped)
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
							viewStore.send(.balanceOperationButtonTapped)
						}
						.symbolVariant(.circle)
					}
				}
				.navigationTitle(viewStore.budget.name)
				.navigationBarTitleDisplayMode(.inline)
				.sheet(
					store: self.store.scope(
						state: \.$editBudget,
						action: { .editBudget($0) }
					)
				) { store in
					NavigationStack {
						BudgetFormView(store: store)
							.navigationTitle("Budget bearbeiten")
							.navigationBarTitleDisplayMode(.inline)
							.toolbar {
								ToolbarItem(placement: .cancellationAction) {
									Button("Abbrechen") {
										viewStore.send(.cancelEditButtonTapped)
									}
								}
								ToolbarItem(placement: .confirmationAction) {
									Button("Fertig") {
										viewStore.send(.saveBudgetButtonTapped)
									}
									//	private var changesArePresent: Bool {
									//		budget.name != name || budget.symbol != symbol || budget.color != color || projectionHasChanged
									//	private var changesArePresent: Bool {
									//		budget.name != name || budget.symbol != symbol || budget.color != color || projectionHasChanged
									//	}
									//
									//	private var projectionHasChanged: Bool {
									//		if let projection = budget.projection {
									//			if projectionIsEnabled {
									//				return projection.monthlyAllocation != monthlyAllocation
									//			} else {
									//				return true
									//			}
									//		} else {
									//			return projectionIsEnabled
									//		}
									//	}
									//	}
									//								.disabled(
									//									viewStore.addBudget?.name.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
									//									viewStore.addBudget?.symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
									//								)
								}
							}
					}
				}
				//				.sheet(isPresented: $isEditing) {
				//					BudgetEditor(budget: budget)
				//						.environmentObject(model)
				//				}
				//				.fullScreenCover(isPresented: $isOperatingOnBalance) {
				//					BalanceOperator(primaryBudgetID: budget.id)
				//						.environmentObject(model)
				//				}
				//				.actionSheet(isPresented: $isBeingDeleted) {
				//					ActionSheet(
				//						title: Text("\(budget.name) löschen"),
				//						message: Text("Möchtest das Budget \(budget.name) wirklich löschen? Dieser Vorgang kann nicht widerrufen werden."),
				//						buttons: [
				//							.destructive(Text("Budget löschen")) {
				//								model.delete(budget: budget.id)
				//								dismiss()
				//							},
				//							.cancel()
				//						]
				//					)
				//				}
			}
		}
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
