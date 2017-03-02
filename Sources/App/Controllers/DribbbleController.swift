//
//  DribbbleController.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 02/03/2017.
//
//

import Vapor
import HTTP
import Fluent
import FluentMySQL

final class DribbbleController {

    let maximeDribbbleId = 8256
    let filippoDribbbleId = 530801
    
    func isFollowingCreators(request: Request) throws -> ResponseRepresentable {
        
        let user = try request.user()
        
        if user.dribbbleId == maximeDribbbleId || user.dribbbleId == filippoDribbbleId{
            // Since those can't follow themselves
            return Response(status: .found, body: "You are one of the creators.")
        }
        
        guard let dribbbleToken = user.dribbbleAccessToken else {
            throw Abort.custom(status: .badRequest, message: "No dribbble token found")
        }
        
        let followsFilippo = try Dribbble.isFollowingUser(token: dribbbleToken, id: filippoDribbbleId)
        let followsMaxime = try Dribbble.isFollowingUser(token: dribbbleToken, id: maximeDribbbleId)
        
        if followsFilippo && followsMaxime{
            return Response(status: .found, body: "You are following all of them.")
        } else {
            return Response(status: .notFound, body: "You are not following all of them.")
        }
        
    }
    
    func followTheCreators(request: Request) throws -> ResponseRepresentable {
        
        let user = try request.user()
        
        guard let dribbbleToken = user.dribbbleAccessToken else {
            throw Abort.custom(status: .badRequest, message: "No dribbble token found")
        }
        
         try background {
            _ = try? Dribbble.followUser(token: dribbbleToken, id: self.filippoDribbbleId)
            _ = try? Dribbble.followUser(token: dribbbleToken, id: self.maximeDribbbleId)
        }
        
        return Response(status: .accepted, body: "Follows are made... This doesn't guarantee they worked.")
    }

}