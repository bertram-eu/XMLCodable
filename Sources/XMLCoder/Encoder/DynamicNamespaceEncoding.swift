//
//  DynamicNamespaceEncoding.swift
//  XMLCodable
//
//  Created by Jendrik Bertram on 15.01.25.
//

import Foundation

public protocol DynamicNamespaceEncoding {
    static func namespaceURI(for key: CodingKey) -> String?
}

extension Array: DynamicNamespaceEncoding where Element: DynamicNamespaceEncoding {
    public static func namespaceURI(for key: CodingKey) -> String? {
        return Element.namespaceURI(for: key)
    }
}

extension DynamicNamespaceEncoding where Self: Collection, Self.Iterator.Element: DynamicNamespaceEncoding {
    public static func namespaceURI(for key: CodingKey) -> String? {
        return Element.namespaceURI(for: key)
    }
}

extension Optional: DynamicNamespaceEncoding where Wrapped: DynamicNamespaceEncoding {
    public static func namespaceURI(for key: CodingKey) -> String? {
        Wrapped.namespaceURI(for: key)
    }
}

extension Attribute: DynamicNamespaceEncoding where Value: Decodable & DynamicNamespaceEncoding {
    public static func namespaceURI(for key: CodingKey) -> String? {
        Value.namespaceURI(for: key)
    }
}

extension Element: DynamicNamespaceEncoding where Value: Decodable & DynamicNamespaceEncoding {
    public static func namespaceURI(for key: CodingKey) -> String? {
        Value.namespaceURI(for: key)
    }
}

extension ElementAndAttribute: DynamicNamespaceEncoding where Value: Decodable & DynamicNamespaceEncoding {
    public static func namespaceURI(for key: CodingKey) -> String? {
        Value.namespaceURI(for: key)
    }
}

extension Intrinsic: DynamicNamespaceEncoding where Value: Decodable & DynamicNamespaceEncoding {
    public static func namespaceURI(for key: CodingKey) -> String? {
        Value.namespaceURI(for: key)
    }
}
