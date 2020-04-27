enum PhoneNumberType {
    case home, cell, business
}

struct PhoneNumber {
    var number = ""
    var type: PhoneNumberType = .cell
}
