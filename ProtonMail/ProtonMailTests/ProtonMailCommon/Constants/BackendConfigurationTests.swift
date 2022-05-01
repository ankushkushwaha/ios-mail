// Copyright (c) 2022 Proton Technologies AG
//
// This file is part of ProtonMail.
//
// ProtonMail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// ProtonMail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with ProtonMail. If not, see https://www.gnu.org/licenses/.

import XCTest
@testable import ProtonMail

class BackendConfigurationTests: XCTestCase {

    private let emptyLaunchArgs = [String]()
    private let uiTestsLaunchArgs = ["-uiTests"]

    private let emptyEnvVars = [String:String]()
    private var apiCustomAPIEnvVars: [String:String]!

    private let customApiDomain = "api.com"
    private let customApiPath = "/custom_api"

    override func setUp() {
        super.setUp()
        apiCustomAPIEnvVars = [
            "MAIL_APP_API_DOMAIN": customApiDomain,
            "MAIL_APP_API_PATH": customApiPath
        ]
    }

    func testSingleton_returnsProdEnv() {
        assertIsProduction(configuration: BackendConfiguration.shared)
    }

    func testInit_whenThereAreNoArgumentsOrVariables_returnsProdEnv() {
        let result = BackendConfiguration(launchArguments: emptyLaunchArgs, environmentVariables: emptyEnvVars)
        assertIsProduction(configuration: result)
    }

    func testInit_whenThereIsUITestsArg_andEnvVarsExist_returnsCustomEnv() {
        let result = BackendConfiguration(launchArguments: uiTestsLaunchArgs, environmentVariables: apiCustomAPIEnvVars)
        XCTAssert(result.environment.appDomain == "protonmail.com")
        XCTAssert(result.environment.apiDomain == customApiDomain)
        XCTAssert(result.environment.apiPath == customApiPath)
    }

    func testInit_whenThereIsUITestsArg_andOneEnvVarIsMissing_returnsProdEnv() {
        var missingEnvVar: [String:String] = apiCustomAPIEnvVars
        missingEnvVar[missingEnvVar.keys.randomElement()!] = nil

        let result = BackendConfiguration(launchArguments: uiTestsLaunchArgs, environmentVariables: missingEnvVar)
        assertIsProduction(configuration: result)
    }

    private func assertIsProduction(configuration: BackendConfiguration)  {
        XCTAssert(configuration.environment.appDomain == "protonmail.com")
        XCTAssert(configuration.environment.apiDomain == "api.protonmail.ch")
        XCTAssert(configuration.environment.apiPath == "")
    }
}

