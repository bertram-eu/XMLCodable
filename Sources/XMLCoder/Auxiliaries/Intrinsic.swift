//
//  Intrinsic.swift
//  XMLCoder
//
//  Created by Jendrik Bertram on 7/7/23.
//

protocol XMLIntrinsicProtocol {}

/** Property wrapper specifying that a given property should be encoded and decoded as an intrinsic value.

 For example, this type
 ```swift
 struct Book: Codable {
     @Intrinsic var value: Int
 }
 ```

 will encode value `Book(value: 42)` as `<Book>42</Book>`. And vice versa,
 it will decode the former into the latter.
 */
@propertyWrapper
public struct Intrinsic<Value>: XMLIntrinsicProtocol {
    public var wrappedValue: Value

    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension Intrinsic: Codable where Value: Codable {
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

extension Intrinsic: Equatable where Value: Equatable {}
extension Intrinsic: Hashable where Value: Hashable {}
extension Intrinsic: Sendable where Value: Sendable {}
