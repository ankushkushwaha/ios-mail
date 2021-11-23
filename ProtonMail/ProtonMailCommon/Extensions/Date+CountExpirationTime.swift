//
//  Date+CountExpirationTime.swift
//  ProtonMail
//
//
//  Copyright (c) 2021 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.

import Crypto
import Foundation

extension Date {

    static var unixDate: Date {
        let time = TimeInterval(CryptoGetUnixTime())
        return Date(timeIntervalSince1970: time)
    }

    var countExpirationTime: String {
        let distance: TimeInterval
        let unixTime = Date.unixDate
        if #available(iOS 13.0, *) {
            distance = unixTime.distance(to: self) + 60
        } else {
            distance = timeIntervalSinceReferenceDate - unixTime.timeIntervalSinceReferenceDate + 60
        }

        if distance > 86_400 {
            let day = Int(distance / 86_400)
            return String.localizedStringWithFormat(LocalString._day, day)
        } else if distance > 3_600 {
            let hour = Int(distance / 3_600)
            return String.localizedStringWithFormat(LocalString._hour, hour)
        } else {
            let minute = Int(distance / 60)
            return String.localizedStringWithFormat(LocalString._minute, minute)
        }
    }

}
