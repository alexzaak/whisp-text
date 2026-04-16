import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage("enableLiveHUD") var enableLiveHUD: Bool = true
}
