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
        try wrappedValue.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        try wrappedValue = .init(from: decoder)
    }
}

extension Intrinsic: Equatable where Value: Equatable {}
extension Intrinsic: Hashable where Value: Hashable {}
