//
//  GOnboardingModel.swift
//  Gnome
//
//  Created by Joe Barbour on 4/29/24.
//

import Foundation

enum OnboardingSubview:Int,CaseIterable,Codable {
    case intro = 1
    case helper = 2
    case tutorial = 3
    case license = 4
    case thankyou = 5
    case complete = 6
    
}

enum OnboardingButtonType {
    case primary
    case secondary
    
}

enum OnboardingStepViewed {
    case seen
    case unseen
    
}

enum OnboardingTutorialStep:String {
    case todo
    case important
    case done
    case passed

}
