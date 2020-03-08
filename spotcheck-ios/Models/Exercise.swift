struct Exercise {
    var name = ""
    var type: ExerciseType?
}

enum ExerciseType: String {
    case Strength = "Strength"
    case Endurance = "Endurance"
    case Flexibility = "Flexibility"
    case Balance = "Balance"
}
