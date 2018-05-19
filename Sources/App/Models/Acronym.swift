import FluentMySQL
import Vapor

final class Acronym: MySQLModel {
    var id: Int?
    var short: String
    var long: String
    var userId: User.ID

    init(short: String, long: String, userId: User.ID) {
        self.short = short
        self.long = long
        self.userId = userId
    }
}

extension Acronym {
    var user: Parent<Acronym, User> {
        return parent(\.userId)
    }
}

/// Make possible the creation of the table on the database
extension Acronym: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addReference(from: \.userId, to: \User.id)
        }
    }
}

/// Inherit from Codable. Make possible for `Acronym` to be encoded to and decoded from HTTP messages.
extension Acronym: Content { }

/// Vapor’s powerful type safety for parameters
extension Acronym: Parameter { }
