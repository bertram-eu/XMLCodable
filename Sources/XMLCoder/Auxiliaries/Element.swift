//
//  XMLElementNode.swift
//  XMLCoder
//
//  Created by Benjamin Wetherfield on 6/4/20.
//

protocol XMLElementProtocol {
    var namespacePrefix: String? { get set }
    var namespaceURI: String? { get set }
}

/** Property wrapper specifying that a given property should be encoded and decoded as an XML element.

 For example, this type
 ```swift
 struct Book: Codable {
     @Element var id: Int
 }
 ```

 will encode value `Book(id: 42)` as `<Book><id>42</id></Book>`. And vice versa,
 it will decode the former into the latter.
 */
@propertyWrapper
public struct Element<Value>: XMLElementProtocol {
    public var wrappedValue: Value
    public var namespacePrefix: String?
    public var namespaceURI: String?
    
    public init(_ wrappedValue: Value, namespacePrefix: String? = nil, namespaceURI: String? = nil) {
        self.wrappedValue = wrappedValue
        self.namespacePrefix = namespacePrefix
        self.namespaceURI = namespaceURI
    }
}

extension Element: Codable where Value: Codable {
    public func encode(to encoder: Encoder) throws {
        if Value.self is AnyOptional.Type {
            try wrappedValue.encode(to: encoder)
        } else {
            let value: Value? = self.wrappedValue
            try value.encode(to: encoder)
        }
    }

    public init(from decoder: Decoder) throws {
        if Value.self is AnyOptional.Type {
            try wrappedValue = Value(from: decoder)
        } else {
            guard let value = try Value?(from: decoder) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode"))
            }
            wrappedValue = value
        }
    }
}

extension Element: XMLDecodableSequence where Value: XMLDecodableSequence {
    public init() {
        self.wrappedValue = .init()
        self.namespacePrefix = nil
        self.namespaceURI = nil
    }
}

extension Element: Equatable where Value: Equatable {}
extension Element: Hashable where Value: Hashable {}
extension Element: Sendable where Value: Sendable {}

extension Element: ExpressibleByIntegerLiteral where Value: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Value.IntegerLiteralType

    public init(integerLiteral value: Value.IntegerLiteralType) {
        wrappedValue = Value(integerLiteral: value)
    }
}

extension Element: ExpressibleByUnicodeScalarLiteral where Value: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: Value.UnicodeScalarLiteralType) {
        wrappedValue = Value(unicodeScalarLiteral: value)
    }

    public typealias UnicodeScalarLiteralType = Value.UnicodeScalarLiteralType
}

extension Element: ExpressibleByExtendedGraphemeClusterLiteral where Value: ExpressibleByExtendedGraphemeClusterLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = Value.ExtendedGraphemeClusterLiteralType

    public init(extendedGraphemeClusterLiteral value: Value.ExtendedGraphemeClusterLiteralType) {
        wrappedValue = Value(extendedGraphemeClusterLiteral: value)
    }
}

extension Element: ExpressibleByStringLiteral where Value: ExpressibleByStringLiteral {
    public typealias StringLiteralType = Value.StringLiteralType

    public init(stringLiteral value: Value.StringLiteralType) {
        wrappedValue = Value(stringLiteral: value)
    }
}

extension Element: ExpressibleByBooleanLiteral where Value: ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Value.BooleanLiteralType

    public init(booleanLiteral value: Value.BooleanLiteralType) {
        wrappedValue = Value(booleanLiteral: value)
    }
}

extension Element: ExpressibleByNilLiteral where Value: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        wrappedValue = Value(nilLiteral: ())
    }
}

protocol XMLOptionalElementProtocol: XMLElementProtocol {
    init()
}

extension Element: XMLOptionalElementProtocol where Value: AnyOptional {
    init() {
        wrappedValue = Value()
    }
}
