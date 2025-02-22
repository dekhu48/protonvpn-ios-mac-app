//
//  Created on 19/9/24.
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

@testable import fusion
import XCTest

extension UIElement {
    
    @discardableResult
    public func tapInCenter(dx: Double = 0.5, dy: Double = 0.5) -> UIElement {
        return tapOnCoordinate(withOffset: CGVector(dx: dx, dy: dy))
    }
    
    /// Forcibly hovers the element if its not hittable.
    ///
    /// - Parameters:
    ///   - dx: The x-coordinate normalized offset. Default value is 0.5.
    ///   - dy: The y-coordinate normalized offset. Default value is 0.5.
    @discardableResult
    public func forceHover(dx: Double = 0.5, dy: Double = 0.5) -> UIElement {
        uiElement()!.forceHover(dx: dx, dy: dy)
        return self
    }
}
