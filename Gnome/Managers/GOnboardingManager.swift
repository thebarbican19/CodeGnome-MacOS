//
//  GOnboardingManager.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation
import Combine

class OnboardingManager:ObservableObject {
    static var shared = OnboardingManager()
    
    @Published public var current:OnboardingSubview = .intro
    @Published public var tutorial:OnboardingTutorialStep = .passed

    private var updates = Set<AnyCancellable>()

    init() {
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
        else if ProcessManager.shared.helper != .allowed {
            self.current = .helper

        }
        else if self.tutorial != .done {
            self.current = .tutorial

        }
        else if LicenseManager.shared.state.state.valid == false {
            self.current = .license

        }
        else if self.onboardingStep(.thankyou) == .unseen {
            self.current = .license

        }
        else {
            self.current = .complete
            
        }
        
    }
    
    public func onboardingAction(button:OnboardingButtonType) {
        if current == .intro {
            switch button {
                case .primary : _ = self.onboardingStep(.intro, insert: true)
                case .secondary : break // TODO: Open Website
                
            }
            
        }
        else if current == .helper {
            switch button {
                case .primary : ProcessManager.shared.processSetup()
                case .secondary : break // TODO: Video to Show How
                
            }
                        
        }
        else if current == .thankyou {
            switch button {
                case .primary : _ = self.onboardingStep(.intro, insert: true)
                case .secondary : break
                
            }
            
        }
        else if current == .tutorial {
            
        }
        else if current == .complete {
            switch button {
                case .primary : _ = self.onboardingStep(.complete, insert: true)
                case .secondary : break
                
            }
            
        }
        
    }
    
    public func onboardingTutorial() {
        guard let task = TaskManager.shared.tasks else {
            self.tutorial = .todo
            return
            
        }
        
        guard let match = task.sorted(by: { $0.created > $1.created }).first(where: { $0.task.lowercased().contains("codegnome") }) else {
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
        
        // TODO: This is my CodeGnome task!!
        
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
