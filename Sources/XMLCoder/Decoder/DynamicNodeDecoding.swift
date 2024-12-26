// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Max Desiatov on 01/03/2019.
//

/** Allows conforming types to specify how its properties will be decoded.

 For example:
 ```swift
 struct Book: Codable, Equatable, DynamicNodeDecoding {
     let id: UInt
     let title: String
     let categories: [Category]

     enum CodingKeys: String, CodingKey {
         case id
         case title
         case categories = "category"
     }

     static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
         switch key {
         case Book.CodingKeys.id: return .attribute
         default: return .element
         }
     }
 }
 ```
 allows XML of this form to be decoded into values of type `Book`:

 ```xml
 <book id="123">
     <title>Cat in the Hat</title>
     <category>Kids</category>
     <category>Wildlife</category>
 </book>
 ```
 */
public protocol DynamicNodeDecoding: Decodable {
    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding
}

extension Array: DynamicNodeDecoding where Element: DynamicNodeDecoding {
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return Element.nodeDecoding(for: key)
    }
}

public extension DynamicNodeDecoding where Self: Collection, Self.Iterator.Element: DynamicNodeDecoding {
    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return Element.nodeDecoding(for: key)
    }
}

extension Optional: DynamicNodeDecoding where Wrapped: DynamicNodeDecoding {
    public static func nodeDecoding(for key: any CodingKey) -> XMLDecoder.NodeDecoding {
        Wrapped.nodeDecoding(for: key)
    }
}

extension Attribute: DynamicNodeDecoding where Value: Encodable & DynamicNodeDecoding {
    public static func nodeDecoding(for key: any CodingKey) -> XMLDecoder.NodeDecoding {
        Value.nodeDecoding(for: key)
    }
}

extension Element: DynamicNodeDecoding where Value: Encodable & DynamicNodeDecoding {
    public static func nodeDecoding(for key: any CodingKey) -> XMLDecoder.NodeDecoding {
        Value.nodeDecoding(for: key)
    }
}

extension ElementAndAttribute: DynamicNodeDecoding where Value: Encodable & DynamicNodeDecoding {
    public static func nodeDecoding(for key: any CodingKey) -> XMLDecoder.NodeDecoding {
        Value.nodeDecoding(for: key)
    }
}

extension Intrinsic: DynamicNodeDecoding where Value: Encodable & DynamicNodeDecoding {
    public static func nodeDecoding(for key: any CodingKey) -> XMLDecoder.NodeDecoding {
        Value.nodeDecoding(for: key)
    }
}
