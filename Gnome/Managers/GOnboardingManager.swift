//
//  GOnboardingManager.swift
//  Gnome
//
//  Created by Joe Barbour on 4/19/24.
//

import Foundation
import Combine

enum OnboardingSubview:Int,CaseIterable,Codable {
    case intro = 1
    case helper = 2
    case license = 3
    case thankyou = 4
    case tutorial = 5
    case complete = 6
    
}

class OnboardingManager:ObservableObject {
    static var shared = OnboardingManager()
    
    @Published public var current:OnboardingSubview = .intro

    private var updates = Set<AnyCancellable>()

}
