// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Max Desiatov on 30/12/2018.
//

/// Type-erased protocol helper for a metatype check in generic `decode`
/// overload. If you custom sequence type is not decoded correctly, try
/// making it confirm to `XMLDecodableSequence`. Default conformances for
/// `Array` and `Dictionary` are already provided by the XMLCoder library.
public protocol XMLDecodableSequence {
    init()
}

extension Array: XMLDecodableSequence {}

extension Dictionary: XMLDecodableSequence {}

extension Optional: XMLDecodableSequence where Wrapped: XMLDecodableSequence {
    public init() {
        self = nil
    }
}

/// Type-erased protocol helper for a metatype check in generic `decode`
/// overload.
public protocol AnyOptional {
    init()
    
    static var wrappedType: Any.Type { get }
}

extension Optional: AnyOptional {
    public init() {
        self = nil
    }
    
    public static var wrappedType: Any.Type {
        return Wrapped.self
    }
}
