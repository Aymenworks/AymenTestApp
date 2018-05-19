//
//  AcronymsController.swift
//  App
//
//  Created by Rebouh Aymen on 18/05/2018.
//

import Foundation
import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        let acronymsInitialRoute = router.grouped("api", "acronyms")
        acronymsInitialRoute.post(Acronym.self, use: create)
        acronymsInitialRoute.get(use: getAll)

        // Acronym.parameter autodetect the type of Acronym id. It also helps for type safery.
        acronymsInitialRoute.get(Acronym.parameter, use: get)
        acronymsInitialRoute.get(Acronym.parameter, "user", use: getUser)
        acronymsInitialRoute.put(Acronym.parameter, use: update)
        acronymsInitialRoute.delete(Acronym.parameter, use: delete)
        acronymsInitialRoute.get("first", use: getFirstAcronym)

        // http://localhost:8080/api/acronyms/search?q=ONU
        acronymsInitialRoute.get("search", use: search)

        // http://localhost:8080/api/acronyms/search?q=ONU
        acronymsInitialRoute.get("searchMultiple", use: searchMultiple)
    }
    
    func getAll(_ req: Request) throws -> Future<[Acronym]> {
        if let sort = req.query[String.self, at: "sort"], sort == "asc" || sort == "desc" {
            return try Acronym.query(on: req).sort(\.short, sort == "asc" ? .ascending : .descending).all()
        } else {
            return Acronym.query(on: req).all()
        }
    }
    
    func create(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
        return acronym.save(on: req)
    }
    
    func get(_ req: Request) throws -> Future<Acronym> {
        // This function performs all the work necessary to get the acronym from the database
        return try req.parameters.next(Acronym.self)
    }
    
    func getUser(_ req: Request) throws -> Future<User> {
        // This function performs all the work necessary to get the acronym from the database
        return try req.parameters.next(Acronym.self)
            .flatMap(to: User.self) { acronym in
               return try acronym.user.get(on: req)
        }
    }
    
    func update(_ req: Request) throws -> Future<Acronym> {
        // dual future form of flatMap, to wait for both the parameter extraction and content decoding to complete.
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self)) { acronym, newAcronym -> Future<Acronym> in
                            acronym.short = newAcronym.short
                            acronym.long = newAcronym.long
                            acronym.userId = newAcronym.userId
                            return acronym.save(on: req)
        }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    func search(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "q"] else { throw Abort(.badRequest) }
        
        return try Acronym.query(on: req)
            // This line below is not type safe
            .filter(\.short, .equals, .data(searchTerm))
            // This line below is type safe
            //.filter(\.short == searchTerm)
            .all()
    }
    
    func searchMultiple(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "q"] else { throw Abort(.badRequest) }
        
        return try Acronym.query(on: req).group(.or) { or in
            try or.filter(\.short, .equals, .data(searchTerm))
            try or.filter(\.long, .equals, .data(searchTerm))
            }.all()
    }
    
    func getFirstAcronym(_ req: Request) throws -> Future<Acronym> {
        return Acronym.query(on: req).first().map(to: Acronym.self) { acronym in
            guard let acronym = acronym else { throw Abort(.notFound) }
            return acronym
        }
    }
}
