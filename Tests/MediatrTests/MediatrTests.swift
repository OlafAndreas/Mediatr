import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MediatrMacros)
import MediatrMacros

let testMacros: [String: Macro.Type] = [
    "requestHandler": RequestHandlersMacro.self,
]
#endif

final class MediatrTests: XCTestCase {
    func testMacro() throws {
        #if canImport(MediatrMacros)
        // TODO: Add tests
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
