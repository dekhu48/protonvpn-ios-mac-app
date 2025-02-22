//
//  Created on 25/04/2024.
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

import SwiftUI

import ComposableArchitecture

struct MainView: View {
    @Bindable var store: StoreOf<MainFeature>

    var body: some View {
        TabView(selection: $store.currentTab.sending(\.selectTab)) {
            NavigationStack {
                HomeLoadingView(store: store.scope(state: \.homeLoading,
                                                   action: \.homeLoading))
            }
            .tag(MainFeature.Tab.home)
            .tabItem { Text("Home", comment: "Title of the tab bar item.") }

            NavigationStack {
                SettingsView(store: store.scope(state: \.settings, 
                                                action: \.settings))
            }
            .tag(MainFeature.Tab.settings)
            .tabItem { Text("Settings", comment: "Title of the tab bar item.") }
        }
        .background(background)
        .animation(.default, value: store.mainBackground)
    }

    @ViewBuilder
    private var background: some View {
        switch store.mainBackground {
        case .clear:
            Color.clear
        case .settingsDrillDown:
            Image(.backgroundStage)
        default:
            HomeBackgroundGradient(mainBackground: store.mainBackground)
        }
    }
}
