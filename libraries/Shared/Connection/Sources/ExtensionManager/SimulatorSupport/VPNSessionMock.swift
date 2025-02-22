//
//  Created on 31/05/2024.
//
//  Copyright (c) 2024 Proton AG
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

#if targetEnvironment(simulator)
import Foundation
import enum NetworkExtension.NEVPNStatus
import Dependencies
import XCTestDynamicOverlay
import ExtensionIPC
import let ConnectionFoundations.log
import struct ConnectionFoundations.LogicalServerInfo

@available(iOS 16, *)
final class VPNSessionMock: VPNSession {
    var connectedDate: Date?
    var connectedServer: LogicalServerInfo = .init(logicalID: "", serverID: "")
    var status: NEVPNStatus {
        didSet {
            NotificationCenter.default.post(name: Notification.Name.NEVPNStatusDidChange, object: self)
        }
    }

    var startupDuration: Duration = .seconds(0) // Time taken to enter the `.connecting` state
    var connectionDuration: Duration = .seconds(1)
    var connectionTask: Task<Void, Error>?
    var disconnectionTask: Task<Void, Error>?
    var lastDisconnectError: Error?
    var messageHandler: ((VPNSessionMock, WireguardProviderRequest) -> WireguardProviderRequest.Response)?

    init(
        status: NEVPNStatus,
        connectedDate: Date? = nil,
        lastDisconnectError: Error? = nil
    ) {
        log.info("VPNSessionMock init")
        self.status = status
        self.connectedDate = connectedDate
        self.lastDisconnectError = lastDisconnectError
    }

    func fetchLastDisconnectError() async throws -> Error? { lastDisconnectError }

    func startTunnel() throws {
        let shouldTransitionToConnectingImmediately = startupDuration == .zero
        if shouldTransitionToConnectingImmediately {
            self.status = .connecting
        }

        connectionTask = Task {
            @Dependency(\.continuousClock) var clock
            if !shouldTransitionToConnectingImmediately {
                try await clock.sleep(for: startupDuration)
                if Task.isCancelled { return }
                self.status = .connecting
            }

            try await clock.sleep(for: connectionDuration)
            if Task.isCancelled { return }

            @Dependency(\.date) var date
            connectedDate = date.now
            self.status = .connected
        }
    }

    func stopTunnel() {
        disconnectionTask = Task {
            @Dependency(\.continuousClock) var clock
            try await clock.sleep(for: .seconds(1))
            status = .disconnected
        }
    }

    // MARK: ProviderMessageSender conformance

    func send(_ message: WireguardProviderRequest) async throws -> WireguardProviderRequest.Response {
        guard let messageHandler else {
            XCTFail("Unimplemented message handler")
            return .error(message: "unimplemented message handler")
        }
        return messageHandler(self, message)
    }
}

@available(iOS 16, *)
enum MessageHandler {
    static let full: (VPNSessionMock, WireguardProviderRequest) -> WireguardProviderRequest.Response = { session, message in
        switch message {
        case .getCurrentLogicalAndServerId:
            return .ok(data: "\(session.connectedServer.logicalID);\(session.connectedServer.serverID)".data(using: .utf8)!)

        case .refreshCertificate:
            @Dependency(\.date) var date
            @Dependency(\.vpnAuthenticationStorage) var storage
            let tomorrow = date.now.addingTimeInterval(.days(1))
            storage.store(.init(certificate: "abcd", validUntil: tomorrow, refreshTime: tomorrow))
            return .ok(data: nil)

        case .setApiSelector:
            return .ok(data: nil)

        default:
            XCTFail("Unimplemented message handler for \(message)")
            return .error(message: "")
        }
    }
}
#endif
