//
//  StringRepresentation.swift
//  CardinalDebugToolkit
//
//  Created by Robin Kunde on 11/3/17.
//

import Foundation

public enum StringRepresentation {
    case full(String, String)
    case summary(String)
}

public func stringRepresentation(value: Any, fullDescription: Bool) -> StringRepresentation {
    let decodedValue: Any
    var isUnarchived = false
    if let data = value as? Data, !data.isEmpty {
        if let unarchivedObject = NSKeyedUnarchiver.unarchiveObject(with: data) {
            isUnarchived = true
            decodedValue = unarchivedObject
        } else if let string = String(data: data, encoding: .utf8) {
            decodedValue = string
        } else {
            decodedValue = data
        }
    } else {
        decodedValue = value
    }

    if let data = decodedValue as? Data {
        if fullDescription {
            return .full("Data", (data as NSData).description)
        } else {
            return .summary("Data: \(data.count) bytes")
        }
    } else if let string = decodedValue as? String {
        if string.isEmpty {
            return .summary("Empty String")
        } else {
            return .full("String", string)
        }
    } else if let date = decodedValue as? Date {
        if fullDescription {
            return .full("Date", date.description)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return .summary(formatter.string(from: date))
        }
    } else if let bool = decodedValue as? Bool {
        return .full("Bool", "\(bool)")
    } else if let number = decodedValue as? NSNumber {
        return .full("Number", "\(number)")
    } else if let array = decodedValue as? NSArray {
        if fullDescription {
            return .full("Array", array.description)
        } else {
            return .summary("Array")
        }
    } else if let dict = decodedValue as? NSDictionary {
        if fullDescription {
            return .full("Dictionary", dict.description)
        } else {
            return .summary("Dictionary")
        }
    } else if let url = decodedValue as? URL {
        return .full("URL", url.description)
    } else if isUnarchived {
        if fullDescription {
            return .full("\(type(of: decodedValue)) (archived)", "\(decodedValue)")
        } else {
            return .summary("\(type(of: decodedValue)) (archived)")
        }
    } else {
        if fullDescription {
            return .full("\(type(of: decodedValue))", "\(decodedValue)")
        } else {
            return .summary("\(type(of: decodedValue))")
        }
    }
}
