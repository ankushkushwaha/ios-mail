//
//  ProtonMailUITests.swift
//  ProtonMail - Created on 3/12/19.
//
//
//  The MIT License
//
//  Copyright (c) 2018 Proton Technologies AG
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
    

import XCTest

class ProtonMailUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        let app = XCUIApplication()
        
        ///Logout first
        let txtusernameTextField = app.textFields["txtUsername"]
        txtusernameTextField.tap()
        txtusernameTextField.typeText("\"this is a text\"")
        
//        let elementsQuery = app.scrollViews.otherElements
//        let txtusernameTextField = elementsQuery.textFields["login_user_name"]
//        txtusernameTextField.tap()
//
//        txtusernameTextField.typeText("\"this is a text\"")
        
//        let txtpasswordSecureTextField = elementsQuery/*@START_MENU_TOKEN@*/.secureTextFields["txtPassword"]/*[[".secureTextFields[\"Password\"]",".secureTextFields[\"txtPassword\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        txtpasswordSecureTextField.tap()
//        elementsQuery/*@START_MENU_TOKEN@*/.buttons["login_button"]/*[[".buttons[\"Login\"]",".buttons[\"login_button\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        //XCTAssertEqual(app.tables/*@START_MENU_TOKEN@*/.staticTexts["Bitwarden"]/*[[".cells[\"Welcome,\\nBitwarden,\\n Monday,\\n\"].staticTexts[\"Bitwarden\"]",".staticTexts[\"Bitwarden\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/, "Bitwarden")
        // app.tables.staticTexts["Bitwarden"].tap()
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
