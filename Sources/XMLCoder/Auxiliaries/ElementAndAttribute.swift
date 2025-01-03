//
//  XMLBothNode.swift
//  XMLCoder
//
//  Created by Benjamin Wetherfield on 6/7/20.
//

protocol XMLElementAndAttributeProtocol {}

/** Property wrapper specifying that a given property should be decoded from either an XML element
 or an XML attribute. When encoding, the value will be present as both an attribute, and an element.

 For example, this type
 ```swift
 struct Book: Codable {
     @ElementAndAttribute var id: Int
 }
 ```

 will encode value `Book(id: 42)` as `<Book id="42"><id>42</id></Book>`. It will decode both
 `<Book><id>42</id></Book>` and `<Book id="42"></Book>` as `Book(id: 42)`.
 */
@propertyWrapper
public struct ElementAndAttribute<Value>: XMLElementAndAttributeProtocol {
    public var wrappedValue: Value

    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension ElementAndAttribute: Codable where Value: Codable {
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

extension ElementAndAttribute: Equatable where Value: Equatable {}
extension ElementAndAttribute: Hashable where Value: Hashable {}
extension ElementAndAttribute: Sendable where Value: Sendable {}
