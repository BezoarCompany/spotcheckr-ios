///LogManager controls which loggers to use. You can add multiple loggers if needed.
final class LogManager: LogManagerProtocol {
    private static var log: Logger = SwiftyBeaverLogger()

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

    static func setLoggingEnabled(_ enabled: Bool) {
        Services.systemService.savePreference(value: enabled, key: "loggingEnabled", success: {
            log = enabled ? SwiftyBeaverLogger() : NullLogger()
        })
    }
}
