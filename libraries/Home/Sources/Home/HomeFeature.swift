//
//  Created on 17.05.23.
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

import SwiftUI
import Foundation

import Dependencies
import ComposableArchitecture

import Domain
import Theme
import VPNShared
import VPNAppCore
import ProtonCoreUIFoundations

import CasePaths

@Reducer
public struct HomeFeature {
    /// - Note: might want this as a property of all Reducer types
    public typealias ActionSender = (Action) -> Void

    @ObservableState
    public struct State: Equatable {
        static let maxConnections = 8

        public var connections: [RecentConnection]

        public var connectionStatus: ConnectionStatusFeature.State
        public var vpnConnectionStatus: VPNConnectionStatus

        public init(connections: [RecentConnection], connectionStatus: ConnectionStatusFeature.State, vpnConnectionStatus: VPNConnectionStatus) {
            self.connections = connections
            self.connectionStatus = connectionStatus
            self.vpnConnectionStatus = vpnConnectionStatus
        }

        public init() {
            let connectionState = ConnectionStatusFeature.State(protectionState: .unprotected)
            self.init(connections: [],
                      connectionStatus: connectionState,
                      vpnConnectionStatus: .disconnected)
        }

        mutating func trimConnections() {
            @Dependency(\.storage) var storage
            while connections.count > Self.maxConnections,
                  let index = connections.lastIndex(where: \.notPinned) {
                connections.remove(at: index)
            }
            try? storage.set(connections, forKey: "RecentConnections")
        }
    }

    public enum Action: Equatable {
        /// Connect to a given connection specification. Bump it to the top of the
        /// list, if it isn't already pinned.
        case connect(ConnectionSpec)
        case disconnect
        /// Pin a recent connection to the top of the list, and remove it from the recent connections.
        case pin(ConnectionSpec)
        /// Remove a connection from the pins, and add it to the top of the recent connections.
        case unpin(ConnectionSpec)
        /// Remove a connection.
        case remove(ConnectionSpec)

        case connectionStatusViewAction(ConnectionStatusFeature.Action)

        /// Show details screen with info about current connection
        case showConnectionDetails

        /// Watch for changes of VPN connection
        case watchConnectionStatus
        /// Process new VPN connection state
        case newConnectionStatus(VPNConnectionStatus)

        /// Start bug report flow
        case helpButtonPressed

        case loadConnections
    }


    private enum CancelId {
        case watchConnectionStatus
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .connect(spec):
                var pinned = false

                if let index = state.connections.firstIndex(where: {
                    $0.connection == spec
                }) {
                    pinned = state.connections[index].pinned
                    state.connections.remove(at: index)
                }
                let recent = RecentConnection(
                    pinned: pinned,
                    underMaintenance: false,
                    connectionDate: Date(),
                    connection: spec
                )
                state.connections.insert(recent, at: 0)
                state.trimConnections()

                return .run { send in
                    @Dependency(\.connectToVPN) var connectToVPN
                    try? await connectToVPN(spec)
                }

            case let .pin(spec):
                guard let index = state.connections.firstIndex(where: {
                    $0.connection == spec
                }) else {
                    state.trimConnections()
                    return .none
                }

                state.connections[index].pinned = true
                state.trimConnections()
                return .none

            case let .unpin(spec):
                guard let index = state.connections.firstIndex(where: {
                    $0.connection == spec
                }) else {
                    state.trimConnections()
                    return .none
                }

                state.connections[index].pinned = false
                state.trimConnections()
                return .none

            case let .remove(spec):
                state.connections.removeAll {
                    $0.connection == spec
                }
                state.trimConnections()
                return .none

            case .disconnect:
                state.connectionStatus.protectionState = .unprotected
                return .run { send in
                    @Dependency(\.disconnectVPN) var disconnectVPN
                    try? await disconnectVPN()
                }

            case .connectionStatusViewAction:
                return .none

            case .watchConnectionStatus:
                return .run { @MainActor send in
                    let stream = Dependency(\.vpnConnectionStatusPublisher)
                        .wrappedValue()
                        .map { Action.newConnectionStatus($0) }

                    for await value in stream {
                        send(value)
                    }
                }
                .cancellable(id: CancelId.watchConnectionStatus)

            case .newConnectionStatus(let connectionStatus):
                state.vpnConnectionStatus = connectionStatus
                return .none
                
            case .showConnectionDetails:
                return .none // Will be handled up the tree of reducers
            case .helpButtonPressed:
                return .none
            case .loadConnections:
                @Dependency(\.storage) var storage
                if let connections = try? storage.get([RecentConnection].self, forKey: "RecentConnections") {
                    state.connections = connections
                }
                return .none
            }
        }
        Scope(state: \.connectionStatus, action: /Action.connectionStatusViewAction) {
            ConnectionStatusFeature()
        }
    }

    public init() {}
}

extension RecentConnection {
    public var icon: Image {
        if pinned {
            return IconProvider.pinFilled
        } else {
            return IconProvider.clockRotateLeft
        }
    }
}

#if DEBUG
extension HomeFeature {
    public static let previewState: State = .init(connections: [.pinnedFastest,
                                                                .previousFreeConnection,
                                                                .connectionSecureCore,
                                                                .connectionRegion,
                                                                .connectionSecureCoreFastest],
                                                  connectionStatus: .init(protectionState: .protected(netShield: .random)),
                                                  vpnConnectionStatus: .disconnected)
}
#endif
