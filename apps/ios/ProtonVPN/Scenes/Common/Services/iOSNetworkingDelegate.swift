//
//  iOSNetworkingDelegate.swift
//  ProtonVPN
//
//  Created by Igor Kulman on 24.08.2021.
//  Copyright © 2021 Proton Technologies AG. All rights reserved.
//

import Foundation
import LegacyCommon
import GoLibs
import ProtonCoreDataModel
import ProtonCoreNetworking
import ProtonCoreServices
import ProtonCoreForceUpgrade
import ProtonCoreHumanVerification
import CommonNetworking

final class iOSNetworkingDelegate: NetworkingDelegate {
    let sessionAuthenticatedEvents: AsyncStream<Bool>

    private let forceUpgradeService: ForceUpgradeDelegate
    private var humanVerify: HumanVerifyDelegate?
    private let alertingService: CoreAlertService

    private let continuation: AsyncStream<Bool>.Continuation

    init(alertingService: CoreAlertService) {
        self.forceUpgradeService = ForceUpgradeHelper(config: .mobile(URL(string: URLConstants.appStoreUrl)!))
        self.alertingService = alertingService

        let (stream, continuation) = AsyncStream<Bool>.makeStream()
        self.sessionAuthenticatedEvents = stream
        self.continuation = continuation
    }

    func set(apiService: APIService) {
        humanVerify = HumanCheckHelper(
            apiService: apiService,
            supportURL: getSupportURL(),
            inAppTheme: { .dark },
            clientApp: ClientApp.vpn
        )
    }

    func onLogout() {
        alertingService.push(alert: RefreshTokenExpiredAlert())
        continuation.yield(false)
    }
}

extension iOSNetworkingDelegate {
    var responseDelegateForLoginAndSignup: HumanVerifyResponseDelegate? {
        get { humanVerify?.responseDelegateForLoginAndSignup }
        set { humanVerify?.responseDelegateForLoginAndSignup = newValue }
    }

    var paymentDelegateForLoginAndSignup: HumanVerifyPaymentDelegate? {
        get { humanVerify?.paymentDelegateForLoginAndSignup }
        set { humanVerify?.paymentDelegateForLoginAndSignup = newValue }
    }

    func onHumanVerify(parameters: HumanVerifyParameters, currentURL: URL?, completion: (@escaping (HumanVerifyFinishReason) -> Void)) {
        humanVerify?.onHumanVerify(parameters: parameters, currentURL: currentURL, completion: completion)
    }

    func getSupportURL() -> URL {
        return URL(string: CoreAppConstants.ProtonVpnLinks.support)!
    }
}

extension iOSNetworkingDelegate {
    func onForceUpgrade(message: String) {
        forceUpgradeService.onForceUpgrade(message: message)
    }
}
