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

import ComposableArchitecture
import protocol Foundation.LocalizedError
import Strings
import SwiftUI

// MARK: - Definitions

extension AlertService.Alert {
    private static var titleFallback: LocalizedStringKey { "Error" }
    private static var messageFallback: LocalizedStringKey { "An error occurred." }
}

extension AlertService {
    public struct Alert: Equatable {
        let title: LocalizedStringKey
        let message: LocalizedStringKey

        init() {
            self.title = Self.titleFallback
            self.message = Self.messageFallback
        }

        init(title: LocalizedStringKey = Self.titleFallback, message: LocalizedStringKey = Self.messageFallback) {
            self.title = title
            self.message = message
        }

        init(title: String? = nil, message: String? = nil) {
            self.title = title.flatMap { LocalizedStringKey($0) } ?? Self.titleFallback
            self.message = message.flatMap { LocalizedStringKey($0) } ?? Self.messageFallback
        }

        init(localizedError: LocalizedError) {
            self.title = localizedError.failureReason.map { .init($0) } ?? Self.titleFallback
            self.message = localizedError.errorDescription.map { .init($0) } ?? Self.messageFallback
        }

        func callAsFunction() -> Self {
            return self
        }
    }
}

// MARK: - Error alerts definitions

let RefreshTokenExpiredAlert = AlertService.Alert(message: Localizable.invalidRefreshTokenPleaseLogin)
let ConnectionFailedAlert = AlertService.Alert(message: Localizable.connectionFailed)

// MARK: - Helpers

extension AlertService.Alert {
    func alertState<Action>(from: Action.Type) -> AlertState<Action> {
        return AlertState<Action>(title: TextState(title), message: TextState(message))
    }
}
