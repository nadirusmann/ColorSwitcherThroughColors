import UIKit

final class HapticService {
    static let shared = HapticService()
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    private var isEnabled: Bool {
        return StorageService.shared.getSettings().vibrationEnabled
    }
    
    func lightImpact() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred()
    }
    
    func mediumImpact() {
        guard isEnabled else { return }
        mediumGenerator.impactOccurred()
    }
    
    func heavyImpact() {
        guard isEnabled else { return }
        heavyGenerator.impactOccurred()
    }
    
    func success() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }
    
    func warning() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.warning)
    }
    
    func error() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }
    
    func selection() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
    }
}
