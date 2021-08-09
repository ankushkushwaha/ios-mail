//
//  MenuLabelTests.swift
//  ProtonMailTests
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

@testable import ProtonMail
import XCTest
import CoreData
import Groot

final class MenuLabelTests: XCTestCase {
    private var menuLabels: [MenuLabel] = []

    override func setUp() {
        let coreDataService = CoreDataService(container: CoreDataStore.shared.memoryPersistentContainer)
        
        let testContext = coreDataService.rootSavingContext
        
        let parsedLabel = testV4LabelData.parseJson()!
        do {
            let labels = try GRTJSONSerialization.objects(withEntityName: Label.Attributes.entityName, fromJSONArray: parsedLabel, in: testContext)
            guard let rawData = labels as? [Label] else {
                XCTAssert(false, "Initialization failed")
                return
            }
            self.menuLabels = Array(labels: rawData, previousRawData: [])
            XCTAssertEqual(self.menuLabels.count, rawData.count)
        } catch {
            XCTAssert(false, "Initialization failed")
        }
        
    }
    
    func testSortout() {
        
        let (labels, folders) = menuLabels.sortoutData()
        XCTAssertEqual(labels.count, 6)
        
        XCTAssertEqual(folders.count, 8)
        XCTAssertEqual(folders.getNumberOfRows(), 13)
        
        let targetID = "McToVpfXly8nccAey391VY652WNF7rtZEeiq6M3E07UYfGu5Bq4pcxpI7jMJQl8zaCZV3T9H8SQ9rHnyOgFKKA=="
        guard let index = folders.getRow(of: targetID) else {
            XCTAssert(false, "Get target folder row failed")
            return
        }
        XCTAssertEqual(index, 3)
        
        guard let label = folders.getLabel(of: targetID) else {
            XCTAssert(false, "Query target folder row failed")
            return
        }
        XCTAssertEqual(label.name, "abjbn")
        XCTAssertEqual(label.deepLevel, 1)
        
        let parentID = "cQj3yw8Pr_FUEs-rvDZr5cMTUo4mGBN_pIoOORQCUKYq_XWErpzIEYODkr4QU7nYt2NQGVKX5db0Cn7DIlrk5w=="
        XCTAssertEqual(label.parentID, parentID)
        
        guard let root = folders.getRootItem(of: label) else {
            XCTAssert(false, "Get root item failed")
            return
        }
        
        XCTAssertEqual(root.location.labelID, parentID)
        XCTAssertEqual(root.name, "saved")
        XCTAssertEqual(root.deepLevel, 3)
        XCTAssertEqual(root.contain(item: label), true)
    }

    func testQueryByIndexPath() {
        let (_, folders) = menuLabels.sortoutData()
        
        let path = IndexPath(row: 5, section: 0)
        guard let label = folders.getFolderItem(by: path) else {
            XCTAssert(false, "Get target folder failed")
            return
        }
        
        let id = "qOEDAmcFE4c9_sD-JV2h6BNPN8pRsWXngWFVA1v0baVCZ8unJvKtaPPE769uFUr85nNowKGVtD2o6zFGXBOHfA=="
        XCTAssertEqual(label.location.labelID, id)
        XCTAssertEqual(label.name, "sub_sub1")
    }
    
    func testIndentationLevel() {
        let label = MenuLabel(id: "id", name: "/name", parentID: nil, path: "a/b/c", textColor: "", iconColor: "", type: -1, order: -1, notify: false)
        label.setupIndentationByPath()
        XCTAssertEqual(label.indentationLevel, 2)
        
        let label2 = MenuLabel(id: "id", name: "/name", parentID: nil, path: #"a\/b\/c"#, textColor: "", iconColor: "", type: -1, order: -1, notify: false)
        label2.setupIndentationByPath()
        XCTAssertEqual(label2.indentationLevel, 0)
    }
    
    func testFlattenSubFolders() {
        let (labels, folders) = menuLabels.sortoutData()
        XCTAssertEqual(labels.count, 6)
        
        XCTAssertEqual(folders[0].flattenSubFolders().count, 1)
        XCTAssertEqual(folders[1].flattenSubFolders().count, 4)
    }
}