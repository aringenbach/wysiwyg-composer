//
// Copyright 2022 The Matrix.org Foundation C.I.C
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// Describe an error occurring during HTML string build.
enum BuildHtmlAttributedError: LocalizedError, Equatable {
    /// Encoding data from raw HTML input failed.
    case dataError(encoding: String.Encoding)

    var errorDescription: String? {
        switch self {
        case .dataError(encoding: let encoding):
            return "Unable to encode string with: \(encoding.description) rawValue: \(encoding.rawValue)"
        }
    }
}

extension NSAttributedString {
    /// Init with HTML string.
    ///
    /// - Parameters:
    ///   - html: Raw HTML string.
    ///   - encoding: Character encoding to use. Default: .utf16.
    convenience init(html: String, encoding: String.Encoding = .utf16) throws {
        guard let data = html.data(using: encoding, allowLossyConversion: false) else {
            throw BuildHtmlAttributedError.dataError(encoding: encoding)
        }
        try self.init(data: data,
                      options: [.documentType: NSAttributedString.DocumentType.html],
                      documentAttributes: nil)
    }

    /// Enumerate attribute for given key and conveniently ignore any attribute that doesn't match given generic type.
    ///
    /// - Parameters:
    ///   - attrName: The name of the attribute to enumerate.
    ///   - enumerationRange: The range over which the attribute values are enumerated. If omitted, the entire range is used.
    ///   - opts: The options used by the enumeration. For possible values, see NSAttributedStringEnumerationOptions.
    ///   - block: The block to apply to ranges of the specified attribute in the attributed string.
    func enumerateTypedAttribute<T>(_ attrName: NSAttributedString.Key,
                                    in enumerationRange: NSRange? = nil,
                                    options opts: NSAttributedString.EnumerationOptions = [],
                                    using block: (T, NSRange, UnsafeMutablePointer<ObjCBool>) -> Void) {
        self.enumerateAttribute(attrName,
                                in: enumerationRange ?? .init(location: 0, length: length),
                                options: opts) { (attr: Any?, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) in
            guard let typedAttr = attr as? T else { return }

            block(typedAttr, range, stop)
        }
    }
}
