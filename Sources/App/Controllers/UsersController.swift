//
//  UsersController.swift
//  App
//
//  Created by Rebouh Aymen on 18/05/2018.
//

import Vapor

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersInitialRoute = router.grouped("api", "users")
        
        usersInitialRoute.get(use: getAll)
        usersInitialRoute.get(User.parameter, use: get)
        usersInitialRoute.get(User.parameter, "acronyms", use: getAcronyms)
        usersInitialRoute.post(User.self, use: create)
        usersInitialRoute.delete(User.parameter, use: delete)
    }
    
    func getAll(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    func get(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    func getAcronyms(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self)
            .flatMap(to: [Acronym].self) { user in
                try user.acronyms.query(on: req).all()
        }
    }
    
    func create(_ req: Request, user: User) throws -> Future<User> {
        return user.save(on: req)
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
}

