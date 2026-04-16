import Foundation

func setupLogging() {
    let logPath = "/Users/Alexander.Zaak/Workspace/zaak.codes/whisp-text/whisptext_debug.log"
    freopen((logPath as NSString).utf8String, "a+", stdout)
    freopen((logPath as NSString).utf8String, "a+", stderr)
    print("=========== WHISPTEXT LOG STARTED ===========")
    print("Date: \(Date())")
}
