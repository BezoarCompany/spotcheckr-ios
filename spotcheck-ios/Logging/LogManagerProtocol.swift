protocol LogManagerProtocol {
    static func verbose(_ message: String)
    static func verbose(_ message: String, _ context: Any?)
    static func debug(_ message: String)
    static func debug(_ message: String, _ context: Any?)
    static func info(_ message: String)
    static func info(_ message: String, _ context: Any?)
    static func warning(_ message: String)
    static func warning(_ message: String, _ context: Any?)
    static func error(_ message: String)
    static func error(_ message: String, _ context: Any?)
}
