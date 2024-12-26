//
//  XMLElementNode.swift
//  XMLCoder
//
//  Created by Benjamin Wetherfield on 6/4/20.
//

/** Property wrapper specifying that a given property should be encoded and decoded as an XML element.

 For example, this type
 ```swift
 struct Book: Codable {
     @Element @Nullable var id: Int?
 }
 ```

 will encode value `Book(id: 42)` as `<Book><id null="true"></id></Book>`. And vice versa,
 it will decode the former into the latter.
 */

protocol XMLNullableElementProtocol {
    init()
}

extension Element: XMLNullableElementProtocol where Value: XMLNullableElementProtocol {
    init() {
        wrappedValue = Value()
    }
}

@propertyWrapper
public struct Nullable<Value>: XMLNullableElementProtocol, AnyOptional where Value: AnyOptional {
    public init() {
        self.wrappedValue = Value()
    }
    
    public static var wrappedType: Any.Type { Value.self }
    
    public var wrappedValue: Value
    
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension Nullable: Codable where Value: Codable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        try wrappedValue = .init(from: decoder)
    }
}

extension Nullable: Equatable where Value: Equatable {}
extension Nullable: Hashable where Value: Hashable {}
extension Nullable: Sendable where Value: Sendable {}

extension Nullable: ExpressibleByIntegerLiteral where Value: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Value.IntegerLiteralType

    public init(integerLiteral value: Value.IntegerLiteralType) {
        wrappedValue = Value(integerLiteral: value)
    }
}

extension Nullable: ExpressibleByUnicodeScalarLiteral where Value: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: Value.UnicodeScalarLiteralType) {
        wrappedValue = Value(unicodeScalarLiteral: value)
    }

    public typealias UnicodeScalarLiteralType = Value.UnicodeScalarLiteralType
}

extension Nullable: ExpressibleByExtendedGraphemeClusterLiteral where Value: ExpressibleByExtendedGraphemeClusterLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = Value.ExtendedGraphemeClusterLiteralType

    public init(extendedGraphemeClusterLiteral value: Value.ExtendedGraphemeClusterLiteralType) {
        wrappedValue = Value(extendedGraphemeClusterLiteral: value)
    }
}

extension Nullable: ExpressibleByStringLiteral where Value: ExpressibleByStringLiteral {
    public typealias StringLiteralType = Value.StringLiteralType

    public init(stringLiteral value: Value.StringLiteralType) {
        wrappedValue = Value(stringLiteral: value)
    }
}

extension Nullable: ExpressibleByBooleanLiteral where Value: ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Value.BooleanLiteralType

    public init(booleanLiteral value: Value.BooleanLiteralType) {
        wrappedValue = Value(booleanLiteral: value)
    }
}

extension Nullable: ExpressibleByNilLiteral where Value: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        wrappedValue = Value(nilLiteral: ())
    }
}
