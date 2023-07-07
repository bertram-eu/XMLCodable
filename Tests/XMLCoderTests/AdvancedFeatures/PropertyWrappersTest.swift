//
//  PropertyWrappersTest.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 17/08/2022.
//

import Foundation
import XCTest
import XMLCodable

private struct Book: Codable, Equatable {
    @Attribute var id: Int
    @Element var name: String
    @Element var title: String?
    @ElementAndAttribute var authorID: Int

    init(id: Int, name: String, title: String? = nil, authorID: Int) {
        _id = Attribute(id)
        _name = Element(name)
        _title = Element(title)
        _authorID = ElementAndAttribute(authorID)
    }
}

private let bookAuthorElementAndAttributeXML =
    """
    <Book id="42" authorID="24">
        <name>The Book</name>
        <authorID>24</authorID>
    </Book>
    """

private let bookAuthorAttributeXML =
    """
    <Book id="42" authorID="24">
        <name>The Book</name>
    </Book>
    """

private let bookAuthorElementXML =
    """
    <Book id="42">
        <authorID>24</authorID>
        <name>The Book</name>
    </Book>
    """

private let book = Book(id: 42, name: "The Book", authorID: 24)

final class PropertyWrappersTest: XCTestCase {
    func testEncode() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted

        let xml = try String(data: encoder.encode(book), encoding: .utf8)

        XCTAssertEqual(bookAuthorElementAndAttributeXML, xml)
    }

    func testDecode() throws {
        let decoder = XMLDecoder()
        let decodedBookBoth = try decoder.decode(Book.self, from: Data(bookAuthorElementAndAttributeXML.utf8))
        let decodedBookElement = try decoder.decode(Book.self, from: Data(bookAuthorElementXML.utf8))
        let decodedBookAttribute = try decoder.decode(Book.self, from: Data(bookAuthorAttributeXML.utf8))

        XCTAssertEqual(book, decodedBookBoth)
        XCTAssertEqual(book, decodedBookElement)
        XCTAssertEqual(book, decodedBookAttribute)
    }
}
