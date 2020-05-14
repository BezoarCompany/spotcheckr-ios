///LogManager controls which loggers to use. You can add multiple loggers if needed.
final class LogManager: LogManagerProtocol {
    private static let log = SwiftyBeaverLogger()

    static func verbose(_ message: String) {
        log.verbose(message)
    }

    static func debug(_ message: String) {
        log.debug(message)
    }

    static func info(_ message: String) {
        log.info(message)
    }

    static func warning(_ message: String) {
        log.warning(message)
    }

    static func error(_ message: String) {
        log.error(message)
    }
}
