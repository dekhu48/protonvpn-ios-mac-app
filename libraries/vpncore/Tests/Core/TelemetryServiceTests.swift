//
//  Created on 04/01/2023.
//
//  Copyright (c) 2023 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import LocalFeatureFlags
import ProtonCoreNetworking
import VPNShared
import XCTest
@testable import vpncore

actor TelemetryAPIImplementationMock: TelemetryAPI {
    func flushEvents(events: [String: Any]) async throws {

    }

    var events = [[String: Any]]()
    func flushEvent(event: [String: Any]) async throws {
        events.append(event)
    }
}

class TelemetryMockFactory: AppStateManagerFactory, NetworkingFactory, PropertiesManagerFactory, VpnKeychainFactory, TelemetrySettingsFactory, TelemetryAPIFactory, AuthKeychainHandleFactory {
    lazy var telemetryApiMock = TelemetryAPIImplementationMock()

    func makeTelemetryAPI(networking: Networking) -> TelemetryAPI { telemetryApiMock }

    func makeVpnKeychain() -> VpnKeychainProtocol { VpnKeychainMock() }

    func makeTelemetrySettings() -> TelemetrySettings { TelemetrySettings(self) }

    func makeNetworking() -> Networking { NetworkingMock() }

    func makePropertiesManager() -> PropertiesManagerProtocol {
        PropertiesManagerMock()
    }

    func makeAppStateManager() -> AppStateManager {
        return appStateManager
    }
    
    func makeAuthKeychainHandle() -> AuthKeychainHandle {
        AuthKeychain(context: .mainApp)
    }

    let appStateManager: AppStateManager

    init(appStateManager: AppStateManager) {
        self.appStateManager = appStateManager
    }
}

class TelemetryTimerMock: TelemetryTimer {
    var reportedConnectionDuration: TimeInterval = 0
    var reportedTimeToConnect: TimeInterval = 0
    func updateConnectionStarted(_ date: Date?) { }
    func markStartedConnecting() { }
    func markFinishedConnecting() { }
    func markConnectionStoped() { }
    var connectionDuration: TimeInterval {
        reportedConnectionDuration
    }

    var timeToConnect: TimeInterval {
        reportedTimeToConnect
    }

    var timeConnecting: TimeInterval {
        0
    }
}

class TelemetryServiceTests: XCTestCase {

    var container: TelemetryMockFactory!
    var service: TelemetryService!
    var appStateManager: AppStateManagerMock!
    var timer: TelemetryTimerMock!

    let vpnGateway = VpnGatewayMock()

    override static func setUp() {
        super.setUp()
        setLocalFeatureFlagOverrides([TelemetryFeature.telemetryOptIn.category: [TelemetryFeature.telemetryOptIn.feature: true,
                                                                                 TelemetryFeature.useBuffer.feature: true]])
    }

    override static func tearDown() {
        setLocalFeatureFlagOverrides(nil)
    }

    override func setUp() async throws {
        try await super.setUp()
        appStateManager = AppStateManagerMock()
        timer = TelemetryTimerMock()
        appStateManager.mockActiveConnection = ConnectionConfiguration.connectionConfig2
        container = TelemetryMockFactory(appStateManager: appStateManager)
        service = await TelemetryServiceImplementation(factory: container, timer: timer, buffer: .init(retrievingFromStorage: true))
    }
}
