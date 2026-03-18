import AVFoundation
import UIKit

final class SoundService {
    static let shared = SoundService()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var systemSoundIDs: [String: SystemSoundID] = [:]
    
    private init() {
        setupAudioSession()
        preloadSounds()
    }
    
    private var isEnabled: Bool {
        return StorageService.shared.getSettings().soundEnabled
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
        }
    }
    
    private func preloadSounds() {
        systemSoundIDs["tap"] = 1104
        systemSoundIDs["success"] = 1025
        systemSoundIDs["fail"] = 1053
        systemSoundIDs["pass"] = 1057
        systemSoundIDs["click"] = 1123
        systemSoundIDs["levelComplete"] = 1028
    }
    
    func playTap() {
        guard isEnabled else { return }
        playSystemSound("tap")
    }
    
    func playColorChange() {
        guard isEnabled else { return }
        playSystemSound("click")
    }
    
    func playPass() {
        guard isEnabled else { return }
        playSystemSound("pass")
    }
    
    func playSuccess() {
        guard isEnabled else { return }
        playSystemSound("success")
    }
    
    func playFail() {
        guard isEnabled else { return }
        playSystemSound("fail")
    }
    
    func playLevelComplete() {
        guard isEnabled else { return }
        playSystemSound("levelComplete")
    }
    
    func playButtonClick() {
        guard isEnabled else { return }
        playSystemSound("click")
    }
    
    private func playSystemSound(_ name: String) {
        guard let soundID = systemSoundIDs[name] else { return }
        AudioServicesPlaySystemSound(soundID)
    }
}
