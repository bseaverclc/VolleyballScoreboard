//
//  Game.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 10/30/21.
//

import Foundation

public class Game
{
    var teams : [String] = []
    var date = Date()
    var redStats = ["Ace": 0, "Kill": 0, "Block" :0, "Blue Err": 0, "Blue Serve Err":0]
    var blueStats = ["Ace": 0, "Kill": 0, "Block" :0, "Red Err": 0, "Red Serve Err":0]
    var redScore = 0
    var blueScore = 0
    
    init(redName: String, blueName: String, currentDate: Date) {
        teams.append(redName)
        teams.append(blueName)
        date = currentDate
    }
    
    
}
