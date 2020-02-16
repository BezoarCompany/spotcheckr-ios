struct Exercise {
    var name = ""
    var type: ExerciseType?
}

enum ExerciseType {
    case Strength, Endurance, Flexibility, Balance
}
