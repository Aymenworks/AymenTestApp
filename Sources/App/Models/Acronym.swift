import FluentMySQL
import Vapor

final class Acronym: MySQLModel {
    var id: Int?

    var short: String
    var long: String

    init(id: Int? = nil, short: String, long: String) {
        self.id = id
        self.short = short
        self.long = long
    }
}

/// Make possible the creation of the table on the database
extension Acronym: Migration { }

/// Inherit from Codable. Make possible for `Acronym` to be encoded to and decoded from HTTP messages.
extension Acronym: Content { }

/// Vapor’s powerful type safety for parameters
extension Acronym: Parameter { }
