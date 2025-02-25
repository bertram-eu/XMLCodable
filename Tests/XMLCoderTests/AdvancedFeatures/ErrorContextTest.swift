// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Matvii Hodovaniuk on 12/27/18.
//

import Foundation
import XCTest
@testable import XMLCodable

final class ErrorContextTest: XCTestCase {
    struct Container: Codable {
        let value: [String: Int]
    }

    func testErrorContextFirstLine() {
        let decoder = XMLDecoder()
        decoder.errorContextLength = 8

        let xmlString = "<blah //>"
        let xmlData = xmlString.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Container.self,
                                                from: xmlData)) { error in
            guard case let DecodingError.dataCorrupted(ctx) = error,
                  let underlying = ctx.underlyingError
            else {
                XCTAssert(false, "wrong error type thrown")
                return
            }

            let column2 = """
            \(underlying.localizedDescription) \
            at line 1, column 2:
            `<blah `
            """
            let column7 = """
            \(underlying.localizedDescription) \
            at line 1, column 7:
            `ah //>`
            """
            let column10 = """
            \(underlying.localizedDescription) \
            at line 1, column 10:
            `//>`
            """

            #if os(Linux) && swift(<5.4)
            // XML Parser returns a different column on Linux and iOS 16+
            // https://bugs.swift.org/browse/SR-11192
            XCTAssertEqual(ctx.debugDescription, column7)
            #elseif os(Windows) || os(Linux)
            XCTAssertEqual(ctx.debugDescription, column10)
            #else
            if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
                XCTAssertEqual(ctx.debugDescription, column7)
            } else {
                XCTAssertEqual(ctx.debugDescription, column2)
            }
            #endif
        }
    }

    // FIXME: not sure why this isn't passing with SwiftFoundation since Swift 5.4
    #if canImport(Darwin) || swift(<5.4)
    func testErrorContext() {
        let decoder = XMLDecoder()
        decoder.errorContextLength = 8

        let xmlString =
            """
            <container>
                test1
            </blah>
            <container>
                test2
            </container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Container.self,
                                                from: xmlData)) { error in
            guard case let DecodingError.dataCorrupted(ctx) = error,
                  let underlying = ctx.underlyingError
            else {
                XCTAssert(false, "wrong error type thrown")
                return
            }

            let line4column1 = """
            \(underlying.localizedDescription) \
            at line 4, column 1:
            `blah>
            <c`
            """

            let line3column8 = """
            \(underlying.localizedDescription) \
            at line 3, column 8:
            `blah>
            <c`
            """

            #if os(Linux)
            // XML Parser returns a different column on Linux
            // https://bugs.swift.org/browse/SR-11192
            XCTAssertEqual(ctx.debugDescription, line4column1)
            #else
            if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
                XCTAssertEqual(ctx.debugDescription, line4column1)
            } else {
                XCTAssertEqual(ctx.debugDescription, line3column8)
            }
            #endif
        }
    }
    #endif

    func testErrorContextSizeOutsizeContent() {
        let decoder = XMLDecoder()
        decoder.errorContextLength = 10

        let xmlString =
            """
            container>
                test1
            </blah>
            <container>
                test2
            </container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Container.self,
                                                from: xmlData)) { error in
            guard case let DecodingError.dataCorrupted(ctx) = error,
                  let underlying = ctx.underlyingError
            else {
                XCTAssert(false, "wrong error type thrown")
                return
            }

            XCTAssertEqual(ctx.debugDescription, """
            \(underlying.localizedDescription) \
            at line 1, column 1:
            `contai`
            """)
        }
    }
}
