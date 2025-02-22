//
//  Created on 28/06/2024.
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

import Foundation

public struct ServerConnectionIntent: Equatable, Sendable {
    public let server: Server
    public let transport: WireGuardTransport
    public let features: VPNConnectionFeatures

    public init(server: Server, transport: WireGuardTransport, features: VPNConnectionFeatures) {
        self.server = server
        self.transport = transport
        self.features = features.copyWithChanged(bouncing: server.endpoint.label)
    }
}
