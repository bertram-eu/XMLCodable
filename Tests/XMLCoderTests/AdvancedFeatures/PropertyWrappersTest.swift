//
//  PropertyWrappersTest.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 17/08/2022.
//

import Foundation
import XCTest
import XMLCodable

private struct Library: Codable, Equatable {
    @Element var name: String
    @Element var books: [Book]?
    @Element var location: String?

    init(name: String, books: [Book]? = nil, location: String? = nil) {
        _name = Element(name)
        _books = Element(books)
        _location = Element(location)
    }

    public enum CodingKeys: String, CodingKey {
        case name = "name"
        case books = "Book"
        case location = "location"
    }
}

private struct Book: Codable, Equatable {
    @Attribute var id: Int
    @Element var name: String
    @Element var title: String?
    @ElementAndAttribute var authorID: Int
    @Element @Nullable var author: Author?

    init(id: Int, name: String, title: String? = nil, authorID: Int, author: Author? = nil) {
        _id = Attribute(id)
        _name = Element(name)
        _title = Element(title)
        _authorID = ElementAndAttribute(authorID)
        _author = Element(Nullable(author))
    }
}

private struct Author: Codable, Equatable {
    @Intrinsic var name: String
    @Attribute var mail: String

    init(name: String, mail: String) {
        _name = Intrinsic(name)
        _mail = Attribute(mail)
    }
}


private let bookAuthorElementAndAttributeXML =
    """
    <Book id="42" authorID="24">
        <name>The Book</name>
        <authorID>24</authorID>
    </Book>
    """

private let bookComplexXML =
    """
    <Book id="42" authorID="24">
        <name>The Book</name>
        <title>The Book</title>
        <authorID>24</authorID>
        <author mail="me@icloud.com">
            Me
        </author>
    </Book>
    """

private let bookEmpyAuthorNameXML =
    """
    <Book id="42" authorID="24">
        <name>The Book</name>
        <title>The Book</title>
        <authorID>24</authorID>
        <author mail="me@icloud.com">
            
        </author>
    </Book>
    """

private let bookNullAuthorXML =
    """
    <Book id="42" authorID="24">
        <name>The Book</name>
        <authorID>24</authorID>
        <author null="true" mail="me@icloud.com"></author>
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

private let libraryElementXML =
    """
    <Library>
        <name>Mine</name>
        <Book id="42" authorID="24">
            <name>The Book</name>
            <authorID>24</authorID>
        </Book>
        <Book id="42" authorID="24">
            <name>The Book</name>
            <title>The Book</title>
            <authorID>24</authorID>
            <author mail="me@icloud.com">
                Me
            </author>
        </Book>
    </Library>
    """

private let book = Book(id: 42, name: "The Book", authorID: 24)
private let bookWithAuthor = Book(id: 42, name: "The Book", title: "The Book", authorID: 24, author: Author(name: "Me", mail: "me@icloud.com"))
private let bookWithEmptyAuthorName = Book(id: 42, name: "The Book", title: "The Book", authorID: 24, author: Author(name: "", mail: "me@icloud.com"))
private let library = Library(name: "Mine", books: [book, bookWithAuthor])

final class PropertyWrappersTest: XCTestCase {
    func testEncode() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted

        let xml = try String(data: encoder.encode(book), encoding: .utf8)

        XCTAssertEqual(bookAuthorElementAndAttributeXML, xml)
    }
    
    func testEncodeComplex() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted

        let xml = try String(data: encoder.encode(bookWithAuthor), encoding: .utf8)

        XCTAssertEqual(bookComplexXML, xml)
    }
    
    func testEncodeEmptyTag() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted

        let xml = try String(data: encoder.encode(bookWithEmptyAuthorName), encoding: .utf8)

        XCTAssertEqual(bookEmpyAuthorNameXML, xml)
    }
    
    func testEncodeArray() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let xml = try String(data: encoder.encode(library), encoding: .utf8)

        XCTAssertEqual(libraryElementXML, xml)
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
    
    func testDecodeComplex() throws {
        let decoder = XMLDecoder()
        let decodedBook = try decoder.decode(Book.self, from: Data(bookComplexXML.utf8))

        XCTAssertEqual(bookWithAuthor, decodedBook)
    }
    
    func testDecodeEmptyTag() throws {
        let decoder = XMLDecoder()
        decoder.removeWhitespaceElements = false
        let decodedBook = try decoder.decode(Book.self, from: Data(bookEmpyAuthorNameXML.utf8))

        XCTAssertEqual(bookWithEmptyAuthorName, decodedBook)
    }
    
    func testDecodeNullTag() throws {
        let decoder = XMLDecoder()
        decoder.removeWhitespaceElements = false
        let decodedBook = try decoder.decode(Book.self, from: Data(bookNullAuthorXML.utf8))
        
        XCTAssertEqual(book, decodedBook)
    }
    
    func testDecodeArray() throws {
        let decoder = XMLDecoder()
        let decodedLibrary = try decoder.decode(Library.self, from: Data(libraryElementXML.utf8))
        
        XCTAssertEqual(library, decodedLibrary)
    }
    
    func testDecodeEmptyArray() throws {
        let decoder = XMLDecoder()
        let decodedLibrary = try decoder.decode(Library.self, from: Data("<Library><name>Mine</name></Library>".utf8))

        XCTAssertEqual(Library(name: "Mine"), decodedLibrary)
    }
}
