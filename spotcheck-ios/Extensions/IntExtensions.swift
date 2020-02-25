extension Int {
    func toFormattedHeight(system: MeasurementSystem = .Imperial) -> String {
        var height = ""
        
        switch system {
        case .Imperial:
            let feet = self / 12
            let inches = self % 12
            
            height = "\(feet)' \(inches)\""
            break
        case .Metric:
            height = "\(self) cm"
            break
        }
        
        return height
    }
    
    func toFormattedWeight(system: MeasurementSystem = .Imperial) -> String {
        var weight = ""
        
        switch system {
        case .Imperial:
            weight = "\(self) lbs."
            break
        case .Metric:
            weight = "\(self) kg"
            break
        }
        
        return weight
    }
}
