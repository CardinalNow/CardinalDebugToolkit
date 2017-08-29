//
//  FilteredLogBuffer.swift
//  CardinalDebugToolkit
//
//  Copyright (c) 2017 Cardinal Solutions (https://www.cardinalsolutions.com/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

public class FilteredLogBuffer {
    public var buffer: [String] = []
    public var filterTag = ""
    public var filterTerm = ""

    public convenience init(tag: String) {
        self.init(tag: tag, term: "")
    }

    public convenience init(term: String) {
        self.init(tag: "", term: term)
    }

    public init(tag: String, term: String) {
        self.filterTag = tag
        self.filterTerm = term
    }

    public func log(formattedMessage: String, message: String, tag: String?) {
        let tagMatches = !filterTag.isEmpty && (tag == filterTag)
        var shouldLogToBuffer = false
        if filterTerm.isEmpty {
            shouldLogToBuffer = tagMatches
        } else if message.contains(filterTerm) {
            shouldLogToBuffer = (filterTag.isEmpty || tagMatches)
        }

        if shouldLogToBuffer {
            DispatchQueue.main.async {
                self.buffer.append(formattedMessage)
            }
        }
    }
}
