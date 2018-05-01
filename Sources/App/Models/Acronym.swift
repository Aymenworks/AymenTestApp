import FluentSQLite
import Vapor

final class Acronym: SQLiteModel {
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

/// Make possible for `Acronym` to be encoded to and decoded from HTTP messages.
extension Acronym: Content { }
