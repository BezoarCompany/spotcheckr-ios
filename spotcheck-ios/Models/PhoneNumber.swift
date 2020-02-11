enum PhoneNumberType {
    case Home, Cell, Business
}

struct PhoneNumber {
    var number = ""
    var type: PhoneNumberType = .Cell
}
