import ComposableArchitecture
import OrderedCollections
import SwiftUI

@Reducer
struct AccountListFeature {
	@ObservableState
	struct State {
		var accounts: Accounts?
		@Presents var destination: Destination.State?
	}
	enum Action: BindableAction {
		case accountRowTapped(Account.ID)
		case binding(BindingAction<State>)
		case createAccountButtonTapped
		case createAccountCancelButtonTapped
		case createAccountSaveButtonTapped
		case destination(PresentationAction<Destination.Action>)
	}
	@Reducer
	enum Destination {
		case createAccount(AccountFormFeature)
		case detail(AccountDetailFeature)
	}
	@Dependency(\.uuid) var uuid
	@Dependency(\.continuousClock) var clock
	@Dependency(\.dataManager.save) var saveData
	var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .accountRowTapped(let accountID):
				guard let accounts = state.accounts else { return .none }
				let account: Account? = { () -> Account? in
					if accounts.primary.id == accountID {
						return accounts.primary
					} else if let account = accounts.remaining[id: accountID] {
						return account
					} else {
						return Account?.none
					}
				}()

				guard let account else { return .none }
				state.destination = .detail(
					AccountDetailFeature.State(account: account)
				)
				return .none
			case .binding:
				return .none
			case .createAccountButtonTapped:
				state.destination = .createAccount(AccountFormFeature.State())
				return .none
			case .createAccountCancelButtonTapped:
				state.destination = nil
				return .none
			case .createAccountSaveButtonTapped:
				guard case .createAccount(let accountForm) = state.destination else { return .none }
				let trimmedName = accountForm.name.trimmingCharacters(in: .whitespacesAndNewlines)
				guard !trimmedName.isEmpty else { return .none }

				let account = Account(id: self.uuid(), name: trimmedName, budgets: [])
				if var accounts = state.accounts {
					accounts.remaining.append(account)
					state.accounts = accounts
				} else {
					state.accounts = Accounts(primary: account)
				}

				state.destination = nil
				return .none
			case .destination(.presented(let destination)):
				return reduceDestination(state: &state, action: destination)
			case .destination:
				return .none
			}
		}
		.ifLet(\.$destination, action: \.destination)

		Reduce { state, _ in
				.run { [accounts = state.accounts] _ in
					enum CancelID { case saveDebounce }
					try await withTaskCancellation(
						id: CancelID.saveDebounce, cancelInFlight: true
					) {
						try await self.clock.sleep(for: .seconds(1))
						try self.saveData(
							JSONEncoder().encode(accounts),
							.accounts
						)
					}
				}
		}
	}

	func reduceDestination(
		state: inout AccountListFeature.State,
		action: Destination.Action
	) -> Effect<AccountListFeature.Action> {
		switch action {
		case .createAccount:
			return .none
		case .detail(.delegate(let delegate)):
			switch delegate {
			case .accountChanged(let account):
				guard var accounts = state.accounts else { return .none }
				if accounts.primary.id == account.id {
					accounts.primary = account
				} else {
					accounts.remaining[id: account.id] = account
				}
				state.accounts = accounts
//			case let .deleteStandup(id: id):
//				state.accounts.remove(id: id)
			}
			return .none
		case .detail:
			return .none
		}
	}
}

struct AccountListView: View {
	@Bindable var store: StoreOf<AccountListFeature>

	var body: some View {
		Group {
			if let accounts = self.store.accounts {
				List {
					Section("Hauptkonto") {
						accountLink(accounts.primary)
					}
					if !accounts.remaining.isEmpty {
						Section("Restliche Konten") {
							ForEach(accounts.remaining) { account in
								accountLink(account)
							}
						}
					}
				}
			} else {
				ContentUnavailableView("Keine Konten", systemImage: "building.columns")
			}
		}
		.navigationTitle("Konten")
		.toolbar {
			ToolbarItem(placement: .bottomBar) {
				Button {
					self.store.send(.createAccountButtonTapped)
				} label: {
					Label("Neues Konto", systemImage: "building.columns")
				}
			}
		}
		.sheet(
			item: self.$store.scope(
				state: \.destination?.createAccount,
				action: \.destination.createAccount
			)
		) { store in
			NavigationStack {
				AccountFormView(store: store)
					.navigationTitle("Neues Konto")
					.navigationBarTitleDisplayMode(.inline)
					.toolbar {
						ToolbarItem(placement: .cancellationAction) {
							Button("Abbrechen") {
								self.store.send(.createAccountCancelButtonTapped)
							}
						}
						ToolbarItem(placement: .confirmationAction) {
							Button("Fertig") {
								self.store.send(.createAccountSaveButtonTapped)
							}
						}
					}
			}
		}
		.navigationDestination(
			item: self.$store.scope(
				state: \.destination?.detail,
				action: \.destination.detail
			)
		) { store in
			AccountDetailView(store: store)
		}
	}

	private func accountLink(_ account: Account) -> some View {
		Button {
			self.store.send(.accountRowTapped(account.id))
		} label: {
			NavigationLink(destination: EmptyView()) {
				AccountRow(account: account)
			}
		}
		.foregroundColor(Color(uiColor: .label))
	}
}

private struct AccountRow: View {
	let account: Account

	var body: some View {
		Label(account.name, systemImage: "building.columns")
			.badge(
				Text(account.balance, format: .eur())
					.monospacedDigit()
			)
	}
}

#Preview {
	NavigationStack {
		AccountListView(
			store: Store(
				initialState: AccountListFeature.State()
			) {
				AccountListFeature()
			} withDependencies: {
				$0.dataManager = .mock(
					initialData: try? JSONEncoder().encode(
						Accounts(
							primary: Account(
								id: UUID(),
								name: "Belizean Heat",
								budgets: []
							),
							remaining: [
								Account(
									id: UUID(),
									name: "Moinsen",
									budgets: []
								)
							]
						)
					)
				)
			}
		)
	}
}
