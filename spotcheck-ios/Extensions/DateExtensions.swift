import Foundation

extension Date {
    init(_ dateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        let date = dateFormatter.date(from: dateString)!
        self.init(timeInterval: 0, since: date)
    }
    
    func toDisplayFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM. dd yyyy"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        return dateFormatter.string(from: self)
    }
}
