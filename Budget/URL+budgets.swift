import Foundation

extension URL {
	static let accounts = Self.documentsDirectory
		.appending(component: "accounts")
		.appendingPathExtension("json")
}
