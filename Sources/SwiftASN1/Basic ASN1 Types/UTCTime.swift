//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftASN1 open source project
//
// Copyright (c) 2022 Apple Inc. and the SwiftASN1 project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftASN1 project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

/// UTCTime represents a date and time.
///
/// In DER format, this is always in the form of `YYMMDDHHMMSSZ`, with no support for fractional seconds.
/// The time is always in the UTC time zone.
///
/// ``UTCTime`` differs from ``GeneralizedTime`` in that it only has support for a two-digit year. This
/// means that it can only encode dates between 1950 and 2049. For dates outside that range, prefer
/// ``GeneralizedTime``.
public struct UTCTime: DERImplicitlyTaggable, BERImplicitlyTaggable, Hashable, Sendable {
    
    public static var defaultIdentifier: ASN1Identifier {
        .utcTime
    }

    /// The numerical year.
    
    public var year: Int {
        get {
            return self._year
        }
        set {
            self._year = newValue
            try! self._validate()
        }
    }

    /// The numerical month.
    
    public var month: Int {
        get {
            return self._month
        }
        set {
            self._month = newValue
            try! self._validate()
        }
    }

    /// The numerical day.
    
    public var day: Int {
        get {
            return self._day
        }
        set {
            self._day = newValue
            try! self._validate()
        }
    }

    /// The numerical hours.
    
    public var hours: Int {
        get {
            return self._hours
        }
        set {
            self._hours = newValue
            try! self._validate()
        }
    }

    /// The numerical minutes.
    
    public var minutes: Int {
        get {
            return self._minutes
        }
        set {
            self._minutes = newValue
            try! self._validate()
        }
    }

    /// The numerical seconds.
    
    public var seconds: Int {
        get {
            return self._seconds
        }
        set {
            self._seconds = newValue
            try! self._validate()
        }
    }

    @usableFromInline var _year: Int
    @usableFromInline var _month: Int
    @usableFromInline var _day: Int
    @usableFromInline var _hours: Int
    @usableFromInline var _minutes: Int
    @usableFromInline var _seconds: Int

    /// Construct a new ``UTCTime`` from individual components.
    ///
    /// - parameters:
    ///     - year: The numerical year. Must be in the range 1950 to 2049.
    ///     - month: The numerical month
    ///     - day: The numerical day
    ///     - hours: The numerical hours
    ///     - minutes: The numerical minutes
    ///     - seconds: The numerical seconds
    
    public init(year: Int, month: Int, day: Int, hours: Int, minutes: Int, seconds: Int) throws {
        self._year = year
        self._month = month
        self._day = day
        self._hours = hours
        self._minutes = minutes
        self._seconds = seconds

        try self._validate()
    }

    
    public init(derEncoded node: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        let content = try ASN1OctetString(derEncoded: node, withIdentifier: identifier).bytes
        self = try TimeUtilities.utcTimeFromBytes(content)
    }

    
    public init(berEncoded node: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        let content = try ASN1OctetString(berEncoded: node, withIdentifier: identifier).bytes
        self = try TimeUtilities.utcTimeFromBytes(content)
    }

    
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        coder.appendPrimitiveNode(identifier: identifier) { bytes in
            bytes.append(self)
        }
    }

    
    func _validate() throws {
        // Validate that the structure is well-formed.
        // UTCTime can only hold years between 1950 and 2049.
        guard self._year >= 1950 && self._year < 2050 else {
            throw ASN1Error.invalidASN1Object(reason: "Invalid year for UTCTime \(self._year)")
        }

        // This also validates the month.
        guard let daysInMonth = TimeUtilities.daysInMonth(self._month, ofYear: self._year) else {
            throw ASN1Error.invalidASN1Object(reason: "Invalid month \(self._month) of year \(self.year) for UTCTime")
        }

        guard self._day >= 1 && self._day <= daysInMonth else {
            throw ASN1Error.invalidASN1Object(reason: "Invalid day \(self._day) of month \(self._month) for UTCTime")
        }

        guard self._hours >= 0 && self._hours < 24 else {
            throw ASN1Error.invalidASN1Object(reason: "Invalid hour for UTCTime \(self._hours)")
        }

        guard self._minutes >= 0 && self._minutes < 60 else {
            throw ASN1Error.invalidASN1Object(reason: "Invalid minute for UTCTime \(self._minutes)")
        }

        // We allow leap seconds here, but don't validate it.
        // This exposes us to potential confusion if we naively implement
        // comparison here. We should consider whether this needs to be transformable
        // to `Date` or similar.
        guard self._seconds >= 0 && self._seconds <= 61 else {
            throw ASN1Error.invalidASN1Object(reason: "Invalid seconds for UTCTime \(self._seconds)")
        }
    }
}

extension UTCTime: Comparable {
    
    public static func < (lhs: UTCTime, rhs: UTCTime) -> Bool {
        if lhs.year < rhs.year { return true } else if lhs.year > rhs.year { return false }
        if lhs.month < rhs.month { return true } else if lhs.month > rhs.month { return false }
        if lhs.day < rhs.day { return true } else if lhs.day > rhs.day { return false }
        if lhs.hours < rhs.hours { return true } else if lhs.hours > rhs.hours { return false }
        if lhs.minutes < rhs.minutes { return true } else if lhs.minutes > rhs.minutes { return false }
        return lhs.seconds < rhs.seconds
    }
}
