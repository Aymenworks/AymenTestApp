//
//  User.swift
//  App
//
//  Created by Rebouh Aymen on 18/05/2018.
//

import Vapor
import FluentMySQL

final class User: MySQLModel {
    var id: Int?
    var name: String
    var username: String
    
    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}

extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.userId)
    }
}

extension User: Migration {}
extension User: Content {}
extension User: Parameter {}
