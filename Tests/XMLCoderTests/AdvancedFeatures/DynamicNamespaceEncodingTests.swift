//
//  DynamicNamespaceEncodingTests.swift
//  XMLCodable
//
//  Created by Jendrik Bertram on 16.01.25.
//

import Testing

import XMLCodable

private struct Library: Codable, Equatable, DynamicNamespaceEncoding {
    var name: String
    var location: String?
    var author: Author
    var books: [Book]?

    init(name: String, location: String? = nil, author: Author, books: [Book]? = nil) {
        self.name = name
        self.location = location
        self.author = author
        self.books = books
    }

    public enum CodingKeys: String, CodingKey {
        case name = "Name"
        case location = "Location"
        case author = "Author"
        case books = "Book"
    }

    static func namespaceURI(for key: any CodingKey) -> String? {
        switch key {
        case CodingKeys.name:
            return "https://www.w3.org/N1"
        default:
            return nil
        }
    }
}

private struct Author: Codable, Equatable, DynamicNamespaceEncoding, DynamicNodeEncoding {
    var name: String

    init(name: String) {
        self.name = name
    }

    public enum CodingKeys: String, CodingKey {
        case name = "Name"
    }

    static func nodeEncoding(for key: any CodingKey) -> XMLCodable.XMLEncoder.NodeEncoding {
        .element
    }

    static func namespaceURI(for key: any CodingKey) -> String? {
        switch key {
        case CodingKeys.name:
            return "https://www.w3.org/N2"
        default:
            return nil
        }
    }
}

private struct Book: Codable, Equatable, DynamicNamespaceEncoding {
    var name: String
    var pages: Int?

    init(name: String, pages: Int? = nil) {
        self.name = name
        self.pages = pages
    }

    public enum CodingKeys: String, CodingKey {
        case name = "Name"
        case pages = "Pages"
    }

    static func namespaceURI(for key: any CodingKey) -> String? {
        switch key {
        case CodingKeys.pages:
            return "https://www.w3.org/2N"
        default:
            return nil
        }
    }
}

private let library = Library(name: "Library Name", location: "Here", author: Author(name: "Me"), books: [Book(name: "Here I am", pages: 43)])

private let libraryXML =
    """
    <Library>
        <n47703:Name xmlns:n47703=\"https://www.w3.org/N1\">Library Name</n47703:Name>
        <Location>Here</Location>
        <Author>
            <n47704:Name xmlns:n47704=\"https://www.w3.org/N2\">Me</n47704:Name>
        </Author>
        <Book>
            <Name>Here I am</Name>
            <n47592:Pages xmlns:n47592=\"https://www.w3.org/2N\">43</n47592:Pages>
        </Book>
    </Library>
    """


struct Test {

    var encoder: XMLEncoder {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dataEncodingStrategy = .base64
        return encoder
    }

    @Test func encoding() async throws {
        let library = Library(name: "Library Name", location: "Here", author: Author(name: "Me"), books: [Book(name: "Here I am", pages: 43)])

        let xml = try String(data: encoder.encode(library), encoding: .utf8)
        #expect(xml == libraryXML)
    }

}
