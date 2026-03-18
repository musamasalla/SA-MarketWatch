//
//  HapticManager.swift
//  SA Market Watch
//
//  Centralized haptic feedback management
//

import SwiftUI
import UIKit

@MainActor
class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    @AppStorage("hapticFeedback") var isEnabled: Bool = true
    
    private init() {}
    
    // MARK: - Impact Feedback
    
    func light() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func medium() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func heavy() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    func soft() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    func rigid() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
    
    // MARK: - Notification Feedback
    
    func success() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func warning() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    func error() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    func selection() {
        guard isEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    // MARK: - Market-Specific Haptics
    
    func priceUp() {
        guard isEnabled else { return }
        // Double tap light — feels like a "bump up"
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            gen.impactOccurred()
        }
    }
    
    func priceDown() {
        guard isEnabled else { return }
        // Heavy single — feels like a "drop"
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    func alertTriggered() {
        guard isEnabled else { return }
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.warning)
    }
    
    func refresh() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
