import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage("enableLiveHUD") var enableLiveHUD: Bool = true
    @AppStorage("modelSize") var modelSize: String = "tiny"
    @AppStorage("language") var language: String = "de"
}
