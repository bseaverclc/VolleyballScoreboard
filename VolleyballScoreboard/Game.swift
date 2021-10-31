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
    var redStats = ["Ace": 0, "Kill": 0, "BLK" :0, "Opponent Err": 0, "Opponent Serv Err":0]
    var blueStats = ["Ace": 0, "Kill": 0, "BLK" :0, "Opponent Err": 0, "Opponent Serv Err":0]
    var redScore = 0
    var blueScore = 0
    
    init(redName: String, blueName: String, currentDate: Date) {
        teams.append(redName)
        teams.append(blueName)
        date = currentDate
    }
    
    
}
