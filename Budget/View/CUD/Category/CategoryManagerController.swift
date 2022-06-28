import Collections
import SwiftUI

struct CategoryManager: UIViewControllerRepresentable {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model
	@State private var categories: OrderedSet<Category>
	
	init(categories: OrderedSet<Category>) {
		_categories = State(initialValue: categories)
	}
	
	func makeUIViewController(context: Context) -> UIViewController {
		let categoryManagerController = CategoryManagerController(categories: categories)
		categoryManagerController.delegate = context.coordinator
		
		let navigationController = UINavigationController()
		navigationController.setViewControllers([categoryManagerController], animated: true)
		return navigationController
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
		
	}
	
	class Coordinator: NSObject, CategoryManagerControllerDelegate {
		private var parent: CategoryManager
		
		init(_ parent: CategoryManager) {
			self.parent = parent
		}
		
		@MainActor func categoryManagerController(_ categoryManagerController: CategoryManagerController, didFinishManagingCategories categories: OrderedSet<Category>) {
			parent.model.set(categories: categories)
			parent.dismiss()
		}
		
		func categoryManagerControllerDidCancel(_ categoryManagerController: CategoryManagerController) {
			parent.dismiss()
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
}


class CategoryManagerController: UITableViewController {
	var categories: OrderedSet<Category>
	var delegate: CategoryManagerControllerDelegate?
	
	init(categories: OrderedSet<Category>) {
		self.categories = categories
		super.init(style: .insetGrouped)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.isEditing = true
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "category")
		
		navigationItem.title = "Kategorien"
		
		navigationItem.setLeftBarButton(
			UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction(title: "Abbrechen") {_ in
				self.delegate?.categoryManagerControllerDidCancel(self)
			}),
			animated: true
		)
		
		navigationItem.setRightBarButtonItems(
			[
				UIBarButtonItem(systemItem: .done, primaryAction: UIAction(title: "Fertig") {_ in
					self.delegate?.categoryManagerController(self, didFinishManagingCategories: self.categories)
				}),
				UIBarButtonItem(title: "Neue Kategorie", image: UIImage(systemName: "folder.badge.plus"), primaryAction: UIAction(title: "Neue Kategorie") {_ in
					self.present(
						UIHostingController(
							rootView: CategoryCreator{ category in
								self.categories.append(category)
								self.tableView.reloadData()
							}
						)
						, animated: true
					)
				})
			],
			animated: true
		)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath)
		var content = cell.defaultContentConfiguration()
		let category = categories.elements[indexPath.row]
		content.text = category.name
		content.image = UIImage(systemName: "circle.fill")
		content.imageProperties.tintColor = UIColor(category.color.swiftUIColor)
		cell.editingAccessoryType = .detailButton
		cell.contentConfiguration = content
		return cell
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
		let category = categories[fromIndexPath.row]
		categories.remove(at: fromIndexPath.row)
		categories.insert(category, at: to.row)
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			categories.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}
	
	override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		present(
			UIHostingController(
				rootView: CategoryEditor(category: categories.elements[indexPath.row], completion: { name, color in
					self.categories.elements[indexPath.row].name = name
					self.categories.elements[indexPath.row].color = color
					self.tableView.reloadData()
				})
			)
			, animated: true
		)
	}
}

protocol CategoryManagerControllerDelegate {
	@MainActor func categoryManagerController(_ categoryManagerController: CategoryManagerController, didFinishManagingCategories categories: OrderedSet<Category>)
	
	func categoryManagerControllerDidCancel(_ categoryManagerController: CategoryManagerController)
}
