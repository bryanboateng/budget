import Foundation

extension URL {
	static let budgets = Self.documentsDirectory
		.appending(component: "budgets")
		.appendingPathExtension("json")
}
