import Foundation

/// Capture payload (schema v2). Capture-only; no credentials or transport fields.
public struct CrashReport: Sendable, Codable, Equatable {
    public static let schemaVersionCurrent = 2

    public let schemaVersion: Int
    public let id: String
    public let timestamp: Date
    /// `fatal` or `error`.
    public let severity: String
    /// `uncaught`, `manual`, `anr`, or `signal`.
    public let kind: String
    public let title: String
    public let detail: String
    public let frames: String?
    public let location: String?
    public let env: CrashEnv
    public let tags: [String: String]
    public let crumbs: [Breadcrumb]
    public let signal: SignalInfo?
    public let anr: AnrInfo?

    public enum CodingKeys: String, CodingKey {
        case schemaVersion = "v"
        case id
        case timestamp = "ts"
        case severity = "sev"
        case kind
        case title
        case detail
        case frames
        case location = "where"
        case env
        case tags
        case crumbs
        case signal = "sig"
        case anr
    }

    public init(
        schemaVersion: Int = CrashReport.schemaVersionCurrent,
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        severity: String,
        kind: String,
        title: String,
        detail: String,
        frames: String? = nil,
        location: String? = nil,
        env: CrashEnv,
        tags: [String: String] = [:],
        crumbs: [Breadcrumb] = [],
        signal: SignalInfo? = nil,
        anr: AnrInfo? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.id = id
        self.timestamp = timestamp
        self.severity = severity
        self.kind = kind
        self.title = title
        self.detail = detail
        self.frames = frames
        self.location = location
        self.env = env
        self.tags = tags
        self.crumbs = crumbs
        self.signal = signal
        self.anr = anr
    }

    public static let sevFatal = "fatal"
    public static let sevError = "error"
    public static let kindUncaught = "uncaught"
    public static let kindManual = "manual"
    public static let kindAnr = "anr"
    public static let kindSignal = "signal"
}

public struct CrashEnv: Sendable, Codable, Equatable {
    public let os: String
    public let osVer: String

    public enum CodingKeys: String, CodingKey {
        case os
        case osVer
    }

    public init(os: String, osVer: String) {
        self.os = os
        self.osVer = osVer
    }
}

public struct Breadcrumb: Sendable, Codable, Equatable {
    public let timestamp: Date
    public let category: String
    public let message: String
    public let data: [String: String]

    public enum CodingKeys: String, CodingKey {
        case timestamp = "ts"
        case category = "cat"
        case message = "msg"
        case data
    }

    public init(
        timestamp: Date = Date(),
        category: String,
        message: String,
        data: [String: String] = [:]
    ) {
        self.timestamp = timestamp
        self.category = category
        self.message = message
        self.data = data
    }
}

public struct SignalInfo: Sendable, Codable, Equatable {
    public let number: Int
    public let name: String
    public let code: Int?

    public enum CodingKeys: String, CodingKey {
        case number = "num"
        case name
        case code
    }

    public init(number: Int, name: String, code: Int? = nil) {
        self.number = number
        self.name = name
        self.code = code
    }
}

public struct AnrInfo: Sendable, Codable, Equatable {
    public let reason: String?
    public let importance: Int?
    public let description: String?

    public init(reason: String? = nil, importance: Int? = nil, description: String? = nil) {
        self.reason = reason
        self.importance = importance
        self.description = description
    }
}
