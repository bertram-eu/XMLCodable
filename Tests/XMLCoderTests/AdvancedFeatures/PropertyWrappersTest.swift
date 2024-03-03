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
    @Element var website: URL
    @Element var logo: Logo?

    init(name: String, books: [Book]? = nil, location: String? = nil, website: URL, logo: Logo? = nil) {
        _name = Element(name)
        _books = Element(books)
        _location = Element(location)
        _website = Element(website)
        _logo = Element(logo)
    }

    public enum CodingKeys: String, CodingKey {
        case name = "name"
        case books = "Book"
        case location = "location"
        case website = "website"
        case logo = "logo"
    }
}

private struct Logo: Codable, Equatable {
    @Attribute public var format: String?
    
    @Intrinsic public var value: Data

    public enum CodingKeys: String, CodingKey {
        case format = "format"
        case value
    }

    public init(_ value: Data,
                format: String? = nil) {
        _format = Attribute(format)
        _value = Intrinsic(value)
    }
}

private struct Book: Codable, Equatable {
    @Attribute var id: Int
    @Element var name: String
    @Element var title: String?
    @ElementAndAttribute var authorID: Int
    @Element @Nullable var author: Author?
    @Element var releasedOn: Date

    init(id: Int, name: String, title: String? = nil, authorID: Int, author: Author? = nil, releasedOn: Date) {
        _id = Attribute(id)
        _name = Element(name)
        _title = Element(title)
        _authorID = ElementAndAttribute(authorID)
        _author = Element(Nullable(author))
        _releasedOn = Element(releasedOn)
    }
}

private struct Author: Codable, Equatable {
    @Intrinsic var name: String
    @Attribute var mail: String
    @Element var bestseller: Bestseller?

    init(name: String, mail: String, bestseller: Bestseller? = nil) {
        _name = Intrinsic(name)
        _mail = Attribute(mail)
        _bestseller = Element(bestseller)
    }
}

private struct Bestseller: Codable, Equatable {
    @Intrinsic var title: String

    init(title: String) {
        _title = Intrinsic(title)
    }
}

private let logoData = "Test Data".data(using: .utf8)!

private let bookAuthorElementAndAttributeXML =
    """
    <Book id="42" authorID="24">
        <name>The Book</name>
        <authorID>24</authorID>
        <releasedOn>2001-01-01T04:43:20.000Z</releasedOn>
    </Book>
    """

private let bookComplexXML =
    """
    <Book id="42" authorID="24">
        <name>The Book</name>
        <title>The Book</title>
        <authorID>24</authorID>
        <author mail="me@icloud.com">Me</author>
        <releasedOn>2001-01-01T04:43:20.000Z</releasedOn>
    </Book>
    """

private let bookReallyComplexXML =
    """
    <Book id="42" authorID="24">
        <name>The Book</name>
        <title>The Book</title>
        <authorID>24</authorID>
        <author mail="me@icloud.com">
            Me
            <bestseller>Unknown Title</bestseller>
        </author>
        <releasedOn>2001-01-01T04:43:20.000Z</releasedOn>
    </Book>
    """

private let bookEmpyAuthorNameXML =
    """
    <Book id="42" authorID="24">
        <name>The Book</name>
        <title>The Book</title>
        <authorID>24</authorID>
        <author mail="me@icloud.com"></author>
        <releasedOn>2001-01-01T04:43:20.000Z</releasedOn>
    </Book>
    """

private let bookNullAuthorXML =
    """
    <Book id="42" authorID="24">
        <name>The Book</name>
        <authorID>24</authorID>
        <author null="true" mail="me@icloud.com"></author>
        <releasedOn>2001-01-01T04:43:20.000Z</releasedOn>
    </Book>
    """

private let bookAuthorAttributeXML =
    """
    <Book id="42" authorID="24">
        <name>The Book</name>
        <releasedOn>2001-01-01T04:43:20.000Z</releasedOn>
    </Book>
    """

private let bookAuthorElementXML =
    """
    <Book id="42">
        <authorID>24</authorID>
        <name>The Book</name>
        <releasedOn>2001-01-01T04:43:20.000Z</releasedOn>
    </Book>
    """

private let libraryElementXML =
    """
    <Library>
        <name>Mine</name>
        <Book id="42" authorID="24">
            <name>The Book</name>
            <authorID>24</authorID>
            <releasedOn>2001-01-01T04:43:20.000Z</releasedOn>
        </Book>
        <Book id="42" authorID="24">
            <name>The Book</name>
            <title>The Book</title>
            <authorID>24</authorID>
            <author mail="me@icloud.com">Me</author>
            <releasedOn>2001-01-01T04:43:20.000Z</releasedOn>
        </Book>
        <website>https://www.google.com</website>
        <logo format="plain/text">\(logoData.base64EncodedString())</logo>
    </Library>
    """

private let logo = Logo(logoData, format: "plain/text")
private let releaseDate = Date(timeIntervalSinceReferenceDate: 1000.0 * 17.0)
private let book = Book(id: 42, name: "The Book", authorID: 24, releasedOn: releaseDate)
private let bookWithAuthor = Book(id: 42, name: "The Book", title: "The Book", authorID: 24, author: Author(name: "Me", mail: "me@icloud.com"), releasedOn: releaseDate)
private let bookWithAuthorAndBestseller = Book(id: 42, name: "The Book", title: "The Book", authorID: 24, author: Author(name: "Me", mail: "me@icloud.com", bestseller: Bestseller(title: "Unknown Title")), releasedOn: releaseDate)
private let bookWithEmptyAuthorName = Book(id: 42, name: "The Book", title: "The Book", authorID: 24, author: Author(name: "", mail: "me@icloud.com"), releasedOn: releaseDate)
private let library = Library(name: "Mine", books: [book, bookWithAuthor], website: URL(string: "https://www.google.com")!, logo: logo)

final class PropertyWrappersTest: XCTestCase {
    var decoder: XMLDecoder {
        let decoder = XMLDecoder()
        decoder.dataDecodingStrategy = .base64
        decoder.dateDecodingStrategy = .custom({ decoder -> Date in
            let c = try decoder.singleValueContainer()
            let dateString = try c.decode(String.self)
            guard !dateString.isEmpty else {
                throw DecodingError.valueNotFound(Date.self, .init(codingPath: decoder.codingPath, debugDescription: "Empty Date"))
            }
            let dateFormatter = ISO8601DateFormatter()
            if dateString.count == 10 {
                dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
            } else if dateString.count == 27 {
                dateFormatter.formatOptions = [.withFullDate, .withTime, .withFractionalSeconds, .withColonSeparatorInTime]
            } else {
                dateFormatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTime, .withColonSeparatorInTimeZone, .withFractionalSeconds]
            }
            let date = dateFormatter.date(from: dateString)
            guard date != nil else {
                throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Invalid Date: \(dateString)"))
            }

            return date!
        })
        return decoder
    }
    
    var encoder: XMLEncoder {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dataEncodingStrategy = .base64
        encoder.dateEncodingStrategy = .custom({ date, encoder in
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTime, .withColonSeparatorInTimeZone, .withFractionalSeconds]
            
            var container = encoder.singleValueContainer()
            try container.encode(dateFormatter.string(from: date))
        })
        return encoder
    }
    
    func testEncode() throws {
        let xml = try String(data: encoder.encode(book), encoding: .utf8)

        XCTAssertEqual(bookAuthorElementAndAttributeXML, xml)
    }
    
    func testEncodeComplex() throws {
        let xml = try String(data: encoder.encode(bookWithAuthor), encoding: .utf8)

        XCTAssertEqual(bookComplexXML, xml)
    }
    
    func testEncodeReallyComplex() throws {
        let xml = try String(data: encoder.encode(bookWithAuthorAndBestseller), encoding: .utf8)

        XCTAssertEqual(bookReallyComplexXML, xml)
    }
    
    func testEncodeEmptyTag() throws {
        let xml = try String(data: encoder.encode(bookWithEmptyAuthorName), encoding: .utf8)

        XCTAssertEqual(bookEmpyAuthorNameXML, xml)
    }
    
    func testEncodeArray() throws {
        let xml = try String(data: encoder.encode(library), encoding: .utf8)

        XCTAssertEqual(libraryElementXML, xml)
    }
    
    func testDecode() throws {
        let decodedBookBoth = try decoder.decode(Book.self, from: Data(bookAuthorElementAndAttributeXML.utf8))
        let decodedBookElement = try decoder.decode(Book.self, from: Data(bookAuthorElementXML.utf8))
        let decodedBookAttribute = try decoder.decode(Book.self, from: Data(bookAuthorAttributeXML.utf8))

        XCTAssertEqual(book, decodedBookBoth)
        XCTAssertEqual(book, decodedBookElement)
        XCTAssertEqual(book, decodedBookAttribute)
    }
    
    func testDecodeComplex() throws {
        let decodedBook = try decoder.decode(Book.self, from: Data(bookComplexXML.utf8))

        XCTAssertEqual(bookWithAuthor, decodedBook)
    }
    
    func testDecodeEmptyTag() throws {
        let decodedBook = try decoder.decode(Book.self, from: Data(bookEmpyAuthorNameXML.utf8))

        XCTAssertEqual(bookWithEmptyAuthorName, decodedBook)
    }
    
    func testDecodeNullTag() throws {
        let decodedBook = try decoder.decode(Book.self, from: Data(bookNullAuthorXML.utf8))
        
        XCTAssertEqual(book, decodedBook)
    }
    
    func testDecodeArray() throws {
        let decodedLibrary = try decoder.decode(Library.self, from: Data(libraryElementXML.utf8))
        
        XCTAssertEqual(library, decodedLibrary)
    }
    
    func testDecodeEmptyArray() throws {
        let decodedLibrary = try decoder.decode(Library.self, from: Data("<Library><name>Mine</name><website>https://www.google.com</website></Library>".utf8))

        XCTAssertEqual(Library(name: "Mine", website: URL(string: "https://www.google.com")!), decodedLibrary)
    }
}
