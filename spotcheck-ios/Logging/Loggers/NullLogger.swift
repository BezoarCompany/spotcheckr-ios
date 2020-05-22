class NullLogger: Logger {
    func verbose(_ message: String) { }

    func verbose(_ message: String, _ context: Any?) { }

    func debug(_ message: String) { }

    func debug(_ message: String, _ context: Any?) { }

    func info(_ message: String) { }

    func info(_ message: String, _ context: Any?) { }

    func warning(_ message: String) { }

    func warning(_ message: String, _ context: Any?) { }

    func error(_ message: String) { }

    func error(_ message: String, _ context: Any?) { }
}
