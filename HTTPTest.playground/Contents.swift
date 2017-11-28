//: Playground - noun: a place where people can play

import UIKit
import Alamofire
import Foundation


var str = "Hello, playground"

let parameters : Parameters = [
    "leftLensRadius" : 2.0,
    "rightLensRadius" : 6.0,
    "angle" : 0.9,
    "attempts" : 5,
    "difficulty" : 3,
    "solved" : "True"
    
]

//Alamofire.request("https://optics-ms.herokuapp.com/", method: .post, parameters: parameters)

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}

Alamofire.request("https://optics-ms.herokuapp.com/", method: .post, parameters: parameters)