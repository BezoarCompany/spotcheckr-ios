struct SemanticVersion {
    var major: String = "0"
    var minor: String = "0"
    var patch: String = "0"
    public var description: String { return "\(major).\(minor).\(patch)" }
}
