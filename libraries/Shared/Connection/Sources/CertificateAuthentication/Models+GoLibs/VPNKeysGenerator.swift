//
//  Created on 04/06/2024.
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
import Dependencies
import func GoLibs.Ed25519NewKeyPair
import ConnectionFoundations

// This should supercede our old VPNShared.VPNKeysGenerator
public struct VPNKeysGenerator: DependencyKey {
    var generateKeys: @Sendable () throws -> VPNKeys

    public static var liveValue: VPNKeysGenerator {
        return .init(generateKeys: {
            var error: NSError?
            let keyPair = Ed25519NewKeyPair(&error)
            if let error {
                throw GoLibsCryptoError.keyGenerationFailure(error)
            }
            guard let keyPair else {
                throw GoLibsCryptoError.missingData(nil)
            }

            do {
                let privateKey = try PrivateKey(keyPair: keyPair)
                let publicKey = try PublicKey(keyPair: keyPair)
                return VPNKeys(privateKey: privateKey, publicKey: publicKey)
            } catch {
                throw GoLibsCryptoError.keyConversionFailure(error)
            }
        })

    }
}

enum GoLibsCryptoError: Error {
    case keyConversionFailure(Error)
    case keyGenerationFailure(Error)
    case missingData(Error?)
}
