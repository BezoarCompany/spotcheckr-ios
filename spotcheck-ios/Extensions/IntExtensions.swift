extension Int {
    func toFormattedHeight(system: MeasurementSystem = .imperial) -> String {
        var height = ""

        switch system {
        case .imperial:
            let feet = self / 12
            let inches = self % 12

            height = "\(feet)' \(inches)\""
            break
        case .metric:
            height = "\(self) cm"
            break
        }

        return height
    }

    func toFormattedWeight(system: MeasurementSystem = .imperial) -> String {
        var weight = ""

        switch system {
        case .imperial:
            weight = "\(self) lbs."
            break
        case .metric:
            weight = "\(self) kg"
            break
        }

        return weight
    }
}
