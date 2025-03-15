import SwiftUI

@main
struct UncrossChickyApp: App {
    @AppStorage("isSoundEffectsOn") private var isBackgroundMusicOn: Bool = false
    private var musicPlayer = MusicPlayer.shared

    init() {
        // Начинаем воспроизведение музыки при запуске приложения, если музыка включена
        if isBackgroundMusicOn {
            musicPlayer.playBackgroundMusic()
        }
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(Navigator.shared) // Передаем навигатор в окружение
                .onChange(of: isBackgroundMusicOn) { newValue in
                    if newValue {
                        musicPlayer.playBackgroundMusic()
                    } else {
                        musicPlayer.stopBackgroundMusic()
                    }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        let currentScreen = Navigator.shared.selectedScreen
        print("Current screen: \(currentScreen)") // Для отладки
        
        switch currentScreen {
        case .PRIZE:
            return .allButUpsideDown
        default:
            return .portrait
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

extension Navigator {
    func updateOrientation() {
        UIViewController.attemptRotationToDeviceOrientation()
    }
}
