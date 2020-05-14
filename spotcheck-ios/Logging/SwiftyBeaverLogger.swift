import SwiftyBeaver

final class SwiftyBeaverLogger: Logger {
    private let log = SwiftyBeaver.self

    init() {
        addLoggingDestinations()
    }

    func verbose(_ message: String) {
        log.verbose(message)
    }

    func debug(_ message: String) {
        log.debug(message)
    }

    func info(_ message: String) {
        log.info(message)
    }

    func warning(_ message: String) {
        log.warning(message)
    }

    func error(_ message: String) {
        log.error(message)
    }

    private func addLoggingDestinations() {
        #if DEVEL
        addConsoleDestination()
        #else
        addSwiftyBeaverPlatformDestination()
        #endif
    }

    private func addConsoleDestination() {
        let console = ConsoleDestination()
        console.asynchronously = false
        log.addDestination(console)
    }

    private func addSwiftyBeaverPlatformDestination() {
        let swiftyBeaverPlatform = SBPlatformDestination(appID: "36rMLk",
                                                         appSecret: "5nj1jMqeyxfdNcmDv4ZCyo3rwZArRm4c",
                                                         encryptionKey: "gbMzywmpqav6jgGSn3b1krxagbCxmej7")
        log.addDestination(swiftyBeaverPlatform)
    }
}
