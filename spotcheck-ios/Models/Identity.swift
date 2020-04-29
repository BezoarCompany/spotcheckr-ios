import Foundation

struct Identity {
    var salutation: String = ""
    var firstName: String = ""
    var middleName: String = ""
    var lastName: String = ""
    var fullName: String {
        get {
            var name = ""

            if !salutation.isEmpty {
                name.append("\(salutation) ")
            }

            name.append("\(firstName)")

            if !middleName.isEmpty {
                name.append(" \(middleName)")
            }

            name.append(" \(lastName)")

            return name
        }
    }
    var gender: String?
    var birthDate: Date?
    var name: String {
        return "\(firstName) \(lastName)"
    }
}
