// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import XCTest
@testable import XMLCodable

private struct SingleContainer: Encodable {
    let element: Element

    enum CodingKeys: String, CodingKey {
        case element
    }
}

private struct KeyedContainer: Encodable {
    let elements: [String: Element]

    enum CodingKeys: String, CodingKey {
        case elements = "element"
    }
}

private struct UnkeyedContainer: Encodable {
    let elements: [Element]

    enum CodingKeys: String, CodingKey {
        case elements = "element"
    }
}

private struct Element: Encodable {
    let key: String = "value"
    let intKey: Int = 42
    let int8Key: Int8 = 42
    let doubleKey: Double = 42.42

    enum CodingKeys: CodingKey {
        case key
        case intKey
        case int8Key
        case doubleKey
    }

    static func nodeEncoding(forKey _: CodingKey) -> XMLEncoder.NodeEncoding {
        return .attribute
    }
}

private struct ComplexUnkeyedContainer: Encodable {
    let elements: [ComplexElement]

    enum CodingKeys: String, CodingKey {
        case elements = "element"
    }
}

private struct ComplexElement: Encodable {
    struct Key: Encodable {
        let a: String
        let b: String
        let c: String
    }

    var key = Key(a: "C", b: "B", c: "A")

    enum CodingKeys: CodingKey {
        case key
    }

    static func nodeEncoding(forKey _: CodingKey) -> XMLEncoder.NodeEncoding {
        return .attribute
    }
}

final class NodeEncodingStrategyTests: XCTestCase {
    func testSingleContainer() {
        guard #available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) else {
            return
        }

        let encoder = XMLEncoder()

        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let container = SingleContainer(element: Element())
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element>
                        <doubleKey>42.42</doubleKey>
                        <int8Key>42</int8Key>
                        <intKey>42</intKey>
                        <key>value</key>
                    </element>
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }

        encoder.nodeEncodingStrategy = .custom { codableType, _ in
            guard let barType = codableType as? Element.Type else {
                return { _ in .default }
            }
            return barType.nodeEncoding(forKey:)
        }

        do {
            let container = SingleContainer(element: Element())
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element doubleKey="42.42" int8Key="42" intKey="42" key=\"value\" />
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
    }

    func testKeyedContainer() {
        guard #available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) else {
            return
        }

        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let container = KeyedContainer(elements: ["first": Element()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element>
                        <first>
                            <doubleKey>42.42</doubleKey>
                            <int8Key>42</int8Key>
                            <intKey>42</intKey>
                            <key>value</key>
                        </first>
                    </element>
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }

        encoder.nodeEncodingStrategy = .custom { codableType, _ in
            guard let barType = codableType as? Element.Type else {
                return { _ in .default }
            }
            return barType.nodeEncoding(forKey:)
        }

        do {
            let container = KeyedContainer(elements: ["first": Element()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element>
                        <first doubleKey="42.42" int8Key="42" intKey="42" key=\"value\" />
                    </element>
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
    }

    func testUnkeyedContainer() {
        guard #available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) else {
            return
        }

        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let container = UnkeyedContainer(elements: [Element(), Element()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element>
                        <doubleKey>42.42</doubleKey>
                        <int8Key>42</int8Key>
                        <intKey>42</intKey>
                        <key>value</key>
                    </element>
                    <element>
                        <doubleKey>42.42</doubleKey>
                        <int8Key>42</int8Key>
                        <intKey>42</intKey>
                        <key>value</key>
                    </element>
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }

        encoder.nodeEncodingStrategy = .custom { codableType, _ in
            guard codableType is [Element].Type else {
                return { _ in .default }
            }
            return Element.nodeEncoding(forKey:)
        }

        do {
            let container = UnkeyedContainer(elements: [Element(), Element()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element doubleKey="42.42" int8Key="42" intKey="42" key=\"value\" />
                    <element doubleKey="42.42" int8Key="42" intKey="42" key=\"value\" />
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
    }

    func testItSortsKeysWhenEncodingAsElements() {
        guard #available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) else {
            return
        }

        let encoder = XMLEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

        do {
            let container = ComplexUnkeyedContainer(elements: [ComplexElement()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element>
                        <key>
                            <a>C</a>
                            <b>B</b>
                            <c>A</c>
                        </key>
                    </element>
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
    }

    func testItSortsKeysWhenEncodingAsAttributes() {
        let encoder = XMLEncoder()
        if #available(macOS 10.13, *) {
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
            encoder.nodeEncodingStrategy = .custom { key, _ in
                if key == ComplexElement.Key.self {
                    return { _ in .attribute }
                }
                return { _ in .element }
            }
        } else {
            return
        }

        do {
            let container = ComplexUnkeyedContainer(elements: [ComplexElement()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container>
                    <element>
                        <key a="C" b="B" c="A" />
                    </element>
                </container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
    }
    

    func testNoEmptyElements() {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.noEmptyElements]

        do {
            let data = try encoder.encode(UnkeyedContainer(elements: []), withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!

            let expected =
                """
                <container></container>
                """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
    }
}
