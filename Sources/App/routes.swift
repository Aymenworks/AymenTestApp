import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    router.get("hello", String.parameter, Int.parameter) { req -> String in
        let name = try req.parameters.next(String.self)
        let age = try req.parameters.next(Int.self)
        return "Hello, \(name)! You are \(age) years old."
    }
    
    router.post("api", "acronyms") { req -> Future<Acronym> in
        return try req.content.decode(Acronym.self)
                              .flatMap(to: Acronym.self) { acronym in
            return acronym.save(on: req)
        }
    }
    
    router.get("api", "acronyms") { req -> Future<[Acronym]> in
        if let sort = req.query[String.self, at: "sort"], sort == "asc" || sort == "desc" {
            return try Acronym.query(on: req).sort(\.short, sort == "asc" ? .ascending : .descending).all()
        } else {
            return Acronym.query(on: req).all()
        }
    }
    
    // http://localhost:8080/api/acronyms/2
    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        // This function performs all the work necessary to get the acronym from the database
        return try req.parameters.next(Acronym.self)
    }
    
    // Acronym.parameter autodetect the type of Acronym id. It also helps for type safery.
    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        // dual future form of flatMap, to wait for both the parameter extraction and content decoding to complete.
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self)) { acronym, newAcronym -> Future<Acronym> in
                            acronym.short = newAcronym.short
                            acronym.long = newAcronym.long
            return acronym.save(on: req)
        }
    }
    
    // http://localhost:8080/api/acronyms/3
    router.delete("api", "acronyms", Acronym.parameter) { req -> Future<HTTPStatus> in
        return try req.parameters.next(Acronym.self)
                        .delete(on: req)
                        .transform(to: HTTPStatus.noContent)
    }
    
    // http://localhost:8080/api/acronyms/search?q=ONU
    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at: "q"] else { throw Abort(.badRequest) }
        
        return try Acronym.query(on: req)
            // This line below is not type safe
            .filter(\.short, .equals, .data(searchTerm))
            // This line below is type safe
            //.filter(\.short == searchTerm)
            .all()
    }
    
    // http://localhost:8080/api/acronyms/search?q=ONU
    router.get("api", "acronyms", "searchMultiple") { req -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at: "q"] else { throw Abort(.badRequest) }
        
        return try Acronym.query(on: req).group(.or) { or in
            try or.filter(\.short, .equals, .data(searchTerm))
            try or.filter(\.long, .equals, .data(searchTerm))
        }.all()
    }
    
    // http://localhost:8080/api/acronyms/first
    router.get("api", "acronyms", "first") { req -> Future<Acronym> in
        return Acronym.query(on: req).first().map(to: Acronym.self) { acronym in
            guard let acronym = acronym else { throw Abort(.notFound) }
            return acronym
        }
    }
}
