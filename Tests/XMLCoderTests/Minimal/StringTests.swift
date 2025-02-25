//
//  StringTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/19/18.
//

import XCTest
@testable import XMLCodable

class StringTests: XCTestCase {
    typealias Value = String

    struct Container: Codable, Equatable {
        let value: Value
    }

    let values: [(Value, String)] = [
        ("", ""),
        ("false", "false"),
        ("-42", "-42"),
        ("42", "42"),
        ("42.0", "42.0"),
        ("foobar", "foobar"),
    ]

    func testMissing() {
        let decoder = XMLDecoder()

        let xmlString = "<container />"
        let xmlData = xmlString.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Container.self, from: xmlData))
    }

    func testAttribute() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.nodeEncodingStrategy = .custom { _, _ in
            { _ in .attribute }
        }

        for (value, xmlString) in values {
            let xmlString =
                """
                <container value="\(xmlString)" />
                """
            let xmlData = xmlString.data(using: .utf8)!

            let decoded = try decoder.decode(Container.self, from: xmlData)
            XCTAssertEqual(decoded.value, value)

            let encoded = try encoder.encode(decoded, withRootKey: "container")
            XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
        }
    }

    func testElement() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.outputFormatting = [.prettyPrinted]

        for (value, xmlString) in values {
            let xmlString =
                """
                <container>
                    <value>\(xmlString)</value>
                </container>
                """
            let xmlData = xmlString.data(using: .utf8)!

            let decoded = try decoder.decode(Container.self, from: xmlData)
            XCTAssertEqual(decoded.value, value)

            let encoded = try encoder.encode(decoded, withRootKey: "container")
            XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
        }
    }

    func testRemoveWhitespaceElements() throws {
        let decoder = XMLDecoder(trimValueWhitespaces: false)
        let xmlString =
            """
            <Container>
                <value>escaped data: &amp;lt;&#xD;&#10;</value>
            </Container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(Container.self, from: xmlData)
        XCTAssertEqual(decoded.value, "escaped data: &lt;\r\n")
    }
}
