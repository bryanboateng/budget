import Foundation

extension UUID: RawRepresentable {
	public var rawValue: String {
		self.uuidString
	}

	public typealias RawValue = String

	public init?(rawValue: RawValue) {
		self.init(uuidString: rawValue)
	}
}
