//
//  GOnboardingManager.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation
import Combine
import AppKit
import SwiftUI

class OnboardingManager:ObservableObject {
    static var shared = OnboardingManager()
    
    @Published public var current:OnboardingSubview? = nil
    @Published public var tutorial:OnboardingTutorialStep = .passed

    @Published public var title:LocalizedStringKey = ""
    @Published public var subtitle:LocalizedStringKey = ""
    @Published public var primary:LocalizedStringKey? = nil
    @Published public var secondary:LocalizedStringKey? = nil
    @Published public var tertiary:LocalizedStringKey? = nil

    private var updates = Set<AnyCancellable>()

    init() {
        $tutorial.removeDuplicates().delay(for: 0.2, scheduler: RunLoop.main).sink { state in
            if state == .passed {
                
            }
            
            NSApp.requestUserAttention(.criticalRequest)
            
        }.store(in: &updates)

        $current.removeDuplicates().delay(for: 0.2, scheduler: RunLoop.main).sink { state in
            if state != nil {
                WindowManager.shared.windowOpen(.main, present: .hide)
                WindowManager.shared.windowOpen(.onboarding, present: .present)
                
            }
            else {
                WindowManager.shared.windowClose(.onboarding, animate: true)
                WindowManager.shared.windowOpen(.main, present: .toggle)

            }
            
        }.store(in: &updates)
        
        ProcessManager.shared.$helper.delay(for: 0.1, scheduler: RunLoop.main).removeDuplicates().sink { _ in
            self.onboardingNextState()

        }.store(in: &updates)
        
        UserDefaults.changed.receive(on: DispatchQueue.main).sink { key in
            if key == .onboardingStep {
                self.onboardingNextState()

            }
            
        }.store(in: &updates)
        
        TaskManager.shared.$tasks.delay(for: 0.1, scheduler: RunLoop.main).removeDuplicates().sink { _ in
            self.onboardingTutorial()
            self.onboardingNextState()

        }.store(in: &updates)
        
        self.onboardingNextState()
        
    }
    
    private func onboardingNextState() {
        if self.onboardingStep(.intro) == .unseen {
            self.current = .intro
            
        }
        else if ProcessManager.shared.helper.flag == false {
            self.current = .helper

        }
        else if self.tutorial != .passed {
            self.current = .tutorial
            
        }
        else if LicenseManager.shared.state.state.valid == false || self.onboardingStep(.license) == .unseen {
            self.current = .license

        }
        else if LicenseManager.shared.state.state == .valid && self.onboardingStep(.thankyou) == .unseen {
            self.current = .thankyou

        }
        else if self.onboardingStep(.complete) == .unseen {
            self.current = .complete
            
        }
        else {
            self.current = nil
            
        }
        
        self.title = self.onboardingTitle()
        self.subtitle = self.onboardingSubtitle()
        self.primary = self.onboardingPrimary()
        self.secondary = self.onboardingSecondary()
        self.tertiary = self.onboardingTertiary()
        
        // TODO: Onboarding Transition Animation!

    }
    
    private func onboardingTitle() -> LocalizedStringKey {
        switch self.current {
            case .intro : return "CodeGnome"
            case .helper : return "Allow the Gnome Access"
            case .license : return "Enter License Key"
            case .thankyou : return "Thank You"
            case .tutorial : return "Create your First Task"
            default : return "All Done"
            
        }
    
    }
    
    private func onboardingSubtitle() -> LocalizedStringKey {
        if self.current == .intro {
            return "All your Inline Todos & Notes in one Place."
            
        }
        else if self.current == .helper {
            switch ProcessManager.shared.helper {
                case .outdated : return "The Gnome Helper requires an Update."
                case .error : return "The Gnome Helper received an error and needs to be restarted. "
                default : return "The Gnome Helper requires special permissions to continuously scan for and import your inline tasks and notes in the background."
                
            }
            
        }
        else if self.current == .license {
            let type:String = LicenseManager.licenseKey == nil ? "trial" : "subscription"
            switch LicenseManager.shared.state.state {
                case .expired : return "Your \(type) has expired. Please enter your License Key."
                default : return "Please enter your License Key or try the 14 day trial"

            }
            
        }
        else if self.current == .thankyou {
            return "Thank you for supporting Indie Developers. We hope you enjoy CodeGnome."
            
        }
        else if self.current == .tutorial {
            switch self.tutorial {
                case .todo : return "Open your Code Editor of choice and create your first Inline-Todo."
                case .important : return "Great, now lets mark a todo as Important by adding exclamation points to the end. The more you add the High level of Importance."
                case .done : return "Now, mark it as Complete by simply deleting it."
                case .passed : return "You did it! There is a few more tricks for pros which you can learn about on our Community GitHub page"
                
            }
            
        }
        else if self.current == .complete || self.current == nil {
            return "Thats it, open CodeGnome from the Dock or with the Keyboard Shorcuts to see all your imported Tasks."
            
        }
        
        return ""
    
    }
    
    private func onboardingPrimary() -> LocalizedStringKey? {
        if self.current == .intro {
            return "Get Started"
            
        }
        else if self.current == .helper {
            switch ProcessManager.shared.helper {
                case .outdated : return "Update"
                case .error : return "Restart"
                default : return "Grant Access"
                
            }

        }
        else if self.current == .license {
            return "Validate"
            
        }
        else if self.current == .thankyou {
            return "Next"
            
        }
        else if self.current == .tutorial {
            return nil
            
        }
        else if self.current == .complete || self.current == nil {
            return "Open CodeGnome"

        }
        
        return nil
        
    }
    
    private func onboardingSecondary() -> LocalizedStringKey? {
        if self.current == .intro {
            return "Community"

        }
        else if self.current == .license {
            switch LicenseManager.shared.state.state {
                case .undetermined : return "Start Trial"
                case .trial : return "Continue Trial"
                default : return nil
                
            }
            
        }
        else if self.current == .tutorial {
            return "Help"
            
        }
        
        return nil
        
    }
    
    private func onboardingTertiary() -> LocalizedStringKey? {
        switch LicenseManager.shared.state.state {
            case .valid : return nil
            case .undetermined : return nil
            default : return "Purchase License"
            
        }
    }
    
    public func onboardingAction(button:OnboardingButtonType) {
        if current == .intro {
            switch button {
                case .primary : _ = self.onboardingStep(.intro, insert: true)
                case .secondary : AppLinks.github.launch()
                case .tertiary : AppLinks.stripe.launch()
                
            }
            
        }
        else if current == .helper {
            switch button {
                case .primary : ProcessManager.shared.processInstallHelper()
                case .secondary : break
                case .tertiary : AppLinks.stripe.launch()

            }
                        
        }
        else if current == .license {
            switch button {
                case .primary : break
                case .secondary : _ = self.onboardingStep(.license, insert: true)
                case .tertiary : AppLinks.stripe.launch()

            }
            
        }
        else if current == .thankyou {
            switch button {
                case .primary : _ = self.onboardingStep(.intro, insert: true)
                case .secondary : break
                case .tertiary : AppLinks.stripe.launch()

            }
            
        }
        else if current == .tutorial {
            switch button {
                case .primary : break
                case .secondary : AppLinks.github.launch()
                case .tertiary : AppLinks.stripe.launch()

            }
            
        }
        else if current == .complete {
            switch button {
                case .primary : _ = self.onboardingStep(.complete, insert: true)
                case .secondary : break
                case .tertiary : AppLinks.stripe.launch()

            }
    
        }
        
    }
    
    public func onboardingTutorial() {
        guard let task = TaskManager.shared.tasks else {
            self.tutorial = .todo
            return
            
        }
        
        guard let match = task.sorted(by: { $0.created > $1.created }).first(where: { $0.task.lowercased().contains("gnome") }) else {
            self.tutorial = .todo
            return
            
        }
        
        if match.importance == .low {
            self.tutorial = .important
            
        }
        else if match.state == .todo {
            self.tutorial = .done
            
        }
        else if match.state == .done {
            self.tutorial =  .passed

        }
                
    }
    
    private func onboardingStep(_ step:OnboardingSubview, insert:Bool = false) -> OnboardingStepViewed {
        var list:Array<OnboardingSubview> = []
        
        if let existing = UserDefaults.object(.onboardingStep) as? [Int] {
            list = existing.compactMap({ OnboardingSubview(rawValue: $0) })
            
        }
        
        if insert == true {
            list.append(step)

            UserDefaults.save(.onboardingStep, value: list.compactMap({ $0.rawValue }))

        }
        
        return list.filter({ $0 == step }).isEmpty ? .unseen : .seen

    }
    
}
