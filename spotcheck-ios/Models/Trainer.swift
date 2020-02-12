import Foundation

class Trainer: User {
    var website: URL!
    var certifications = [Certification]()
    var occupationCompany: String? = ""
    var occupationTitle: String? = ""
    var occupation: String {
        get {
            var occupation = "\(occupationTitle!)"
            if !(occupationCompany?.isEmpty ?? true) {
                occupation.append(" at \(occupationCompany!)")
            }
            return occupation
        }
    }
}
