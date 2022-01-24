//
//  Point.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 1/15/22.
//

import Foundation

public class Point: Codable{
    var serve: String
    var redRotation: Int
    var blueRotation: Int
    var who: String
    var why: String
    var score: String
    var uid = ""
    
    init(serve: String, redRotation: Int, blueRotation: Int, who: String, why: String, score: String){
        self.serve = serve
        self.redRotation = redRotation
        self.blueRotation = blueRotation
        self.who = who
        self.why = why
        self.score = score
    }
    
    init(key: String, dict: [String: Any]){
        uid = key
        serve  = dict["serve"] as! String
        redRotation = dict["redRotation"] as! Int
        blueRotation = dict["blueRotation"] as! Int
        who = dict["who"] as! String
        why = dict["why"] as! String
        score = dict["score"] as! String
    }
    
    
}
