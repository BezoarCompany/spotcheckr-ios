import Foundation

struct Identity {
    var salutation: String = ""
    var firstName: String = ""
    var middleName: String = ""
    var lastName: String = ""
    var fullName: String {
        get {
            return middleName.isEmpty ? "\(firstName) \(lastName)" : "\(firstName) \(middleName) \(lastName)"
        }
    }
    var gender: String?
    var birthDate: Date?
}
