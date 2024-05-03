//
//  GUpdateManager.swift
//  Gnome
//
//  Created by Joe Barbour on 5/2/24.
//

import Foundation
import Sparkle
import Combine
import AppKit

class UpdateManager: NSObject,SPUUpdaterDelegate,ObservableObject {
    static var shared = UpdateManager()
    
    @Published var state:UpdateState = .complete
    @Published var available:UpdatePayloadObject?

    private let driver = SPUStandardUserDriver(hostBundle: Bundle.main, delegate: nil)

    private var updates = Set<AnyCancellable>()
    private var updater:SPUUpdater?
    
    override init() {
        super.init()
        
        DispatchQueue.main.async {
            self.updater = SPUUpdater(hostBundle: Bundle.main, applicationBundle: Bundle.main, userDriver: self.driver, delegate: self)
            self.updater?.automaticallyChecksForUpdates = true
            self.updater?.automaticallyDownloadsUpdates = true
            self.updater?.updateCheckInterval = 60.0 * 60.0 * 12
            
            do {
                try self.updater?.start()
                
            }
            catch {
                
            }
            
        }

    }
    
    public func updateCheck(_ forground:Bool) {
        switch forground {
            case true : self.updater?.checkForUpdates()
            case false : self.updater?.checkForUpdatesInBackground()
            
        }
        
        self.state = .checking

    }
    
    func updater(_ updater: SPUUpdater, willInstallUpdateOnQuit item: SUAppcastItem, immediateInstallationBlock immediateInstallHandler: @escaping () -> Void) -> Bool {
        immediateInstallHandler()
        return true
        
    }
    
    func updater(_ updater: SPUUpdater, shouldPostponeRelaunchForUpdate item: SUAppcastItem, untilInvokingBlock installHandler: @escaping () -> Void) -> Bool {
        return false
        
    }
    
    func updaterShouldDownloadReleaseNotes(_ updater: SPUUpdater) -> Bool {
        return true
        
    }

    func checkForUpdatesAndDownloadIfNeeded() {
        self.updater?.checkForUpdatesInBackground()
        
    }

    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        if let date = item.date, let title = item.title, let _ = item.propertiesDictionary["markdown"] as? String {
            let id = item.propertiesDictionary["id"] as! String
            let build = item.propertiesDictionary["sparkle:shortVersionString"] as? Double ?? 0.0
            let timestamp:Date = date
            let version:UpdateVersionObject = .init(formatted: title, numerical: build)

            print("item.propertiesDictionary" ,item.propertiesDictionary)
            
            DispatchQueue.main.async {
                self.available = .init(id: id, created: timestamp, name: title, version: version)
                self.state = .complete
                                
            }
                        
        }
        else {
            DispatchQueue.main.async {
                self.state = .failed
                
            }
            
        }
      
    }
    
    func updater(_ updater: SPUUpdater, failedToDownloadUpdate item: SUAppcastItem, error: Error) {
        print("update could not get update", error)

    }
    
    func updater(_ updater: SPUUpdater, failedToDownloadAppcastWithError error: Error) {
        // Handle the case when the appcast fails to download
        print("update could not get appcast", error)
        
    }
    
    func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        print("No updates" ,updater)
        DispatchQueue.main.async {
            self.available = nil
            self.state = .complete
            
        }

    }
    
    func updater(_ updater: SPUUpdater, willShowModalAlert alert: NSAlert) {
        
    }
    
    func feedURLString(for updater: SPUUpdater) -> String? {
        return "https://ovatar.io/api/version?id=com.ovatar.gnome&beta=false"
        
    }
    
    func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        if let error = error as NSError? {
            DispatchQueue.main.async {
                switch error.code {
                    case 1001 : self.state = .complete
                    default : self.state = .failed
                    
                }
                
            }
            
            if error.code == 4005 {
                //WindowManager.shared.windowOpenWebsite(.update, view: .main)
                
            }
            
        }

    }
    
}

@objc class UpdateDriver: NSObject, SPUUserDriver {
    func show(_ request: SPUUpdatePermissionRequest) async -> SUUpdatePermissionResponse {
        return SUUpdatePermissionResponse(automaticUpdateChecks: true, sendSystemProfile: true)

    }
    
    func showUserInitiatedUpdateCheck(cancellation: @escaping () -> Void) {
        // Ideally we should show progress but do nothing for now
    }

    func showUpdateFound(with appcastItem: SUAppcastItem, state: SPUUserUpdateState) async -> SPUUserUpdateChoice {
        return .install
        
    }
    
    func showUpdateReleaseNotes(with downloadData: SPUDownloadData) {
        
    }
    
    func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error) {
        
    }
    
    func showUpdateNotFoundWithError(_ error: Error, acknowledgement: @escaping () -> Void) {
        
    }
    
    func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {
        print("error")
    }
    
    func showDownloadInitiated(cancellation: @escaping () -> Void) {
        
    }
    
    func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        
    }
    
    func showDownloadDidReceiveData(ofLength length: UInt64) {
        
    }
    
    func showDownloadDidStartExtractingUpdate() {
        
    }
    
    func showExtractionReceivedProgress(_ progress: Double) {
        
    }
    
    func showReadyToInstallAndRelaunch() async -> SPUUserUpdateChoice {
        return .install
        
    }
    
    func showInstallingUpdate(withApplicationTerminated applicationTerminated: Bool, retryTerminatingApplication: @escaping () -> Void) {
        
    }
    
    func showUpdateInstalledAndRelaunched(_ relaunched: Bool, acknowledgement: @escaping () -> Void) {
        
    }
    
    func showUpdateInFocus() {
        
    }
    
    func dismissUpdateInstallation() {
        
    }
}
