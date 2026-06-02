// This implementation is considered as copyleft from public domain.

#if canImport(OSLog)
import OSLog
#endif

extension Process {
  public static func consoleLog<S: StringProtocol>(_ msg: S) {
    let msgStr = msg.description
    #if canImport(Darwin)
    if #available(macOS 26.0, *) {
      #if canImport(OSLog)
      let logger = Logger(subsystem: "EmojiIM", category: "Log")
      logger.log(level: .default, "\(msgStr, privacy: .public)")
      return
      #endif
    }
    NSLog(msgStr)
    #else
    print(msgStr)
    #endif
  }
}
