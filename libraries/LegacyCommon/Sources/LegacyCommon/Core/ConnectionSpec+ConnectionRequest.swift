//
//  Created on 16/10/2024.
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

import Domain

import ProtonCoreFeatureFlags

extension ConnectionSpec {
    public init(connectionRequest: ConnectionRequest) {
        let location: ConnectionSpec.Location
        var features: Set<ConnectionSpec.Feature> = []
        switch connectionRequest.connectionType {
        case .fastest:
            location = connectionRequest.serverType == .secureCore ? .secureCore(.fastest) : .fastest
        case .random:
            location = connectionRequest.serverType == .secureCore ? .secureCore(.random) : .random
        case .country(let country, let type):
            switch type {
            case .fastest:
                if connectionRequest.serverType == .secureCore {
                    location = .secureCore(.fastestHop(to: country))
                } else {
                    location = .region(code: country)
                }
            case .random:
                location = .region(code: country)
            case .server(let serverModel):
                if serverModel.feature.contains(.streaming) {
                    features.insert(.streaming)
                }
                if serverModel.feature.contains(.p2p) {
                    features.insert(.p2p)
                }
                if serverModel.feature.contains(.tor) {
                    features.insert(.tor)
                }
                if serverModel.feature.contains(.secureCore) {
                    location = .secureCore(.hop(to: serverModel.exitCountryCode, via: serverModel.entryCountryCode))
                } else {
                    location = .exact(
                        .paid,
                        number: serverModel.serverNameComponents.sequence,
                        subregion: serverModel.city,
                        regionCode: country
                    )
                }
            }
        case .city(let country, let city):
            location = .exact(.paid, number: nil, subregion: city, regionCode: country)
        }
        self = .init(location: location, features: features, profileId: connectionRequest.profileId)
    }
}
