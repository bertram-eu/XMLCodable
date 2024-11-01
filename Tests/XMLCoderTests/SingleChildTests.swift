// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Max Desiatov on 18/01/2019.
//

import XCTest
@testable import XMLCodable

private struct ProudParent: Codable, Equatable {
    var myChildAge: [Int]
}

final class SingleChildTest: XCTestCase {
    func testEncoder() throws {
        let encoder = XMLEncoder()

        let parent = ProudParent(myChildAge: [2])
        let expectedXML =
            """
            <ProudParent><myChildAge>2</myChildAge></ProudParent>
            """.data(using: .utf8)!

        let encodedXML = try encoder.encode(parent, withRootKey: "ProudParent")

        XCTAssertEqual(expectedXML, encodedXML)
    }

    func testDecoder() throws {
        let decoder = XMLDecoder()

        let parent = ProudParent(myChildAge: [2])
        let xml =
            """
            <ProudParent><myChildAge>2</myChildAge></ProudParent>
            """.data(using: .utf8)!

        let decoded = try decoder.decode(ProudParent.self, from: xml)

        XCTAssertEqual(decoded, parent)
    }
}
