//
//  Game.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 10/30/21.
//

import Foundation
import Firebase

public class Game: Codable{
    var teams : [String] = []
    var setWins: [Int] = [0,0]
    var date : Date
    var sets : [ASet]
    var uid : String?
    
    
    
    init(teams: [String], date: Date) {
        self.teams = teams
        self.date = date
        sets = [ASet]()
        
    }
    
    func saveToFirebase()
    {
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        let dateString = formatter1.string(from: date)
        
        let ref = Database.database().reference()
        let dict = ["teams": self.teams, "setWins":self.setWins, "date": dateString] as [String : Any]
       
        
        let gameRef = ref.child("games").childByAutoId()
        uid = gameRef.key
        gameRef.setValue(dict)
        
        for set in sets{
            let setDict = ["redStats": set.redStats,"blueStats": set.blueStats, "redScore":set.redScore, "blueScore": set.blueScore] as [String : Any]
            let setsID = gameRef.child("sets").childByAutoId()
            set.uid = setsID.key
            setsID.setValue(setDict)
            
        }
        
    }
    
    func updateFirebase()
    {
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        let dateString = formatter1.string(from: date)
        
        var ref = Database.database().reference().child("games").child(uid!)
        let dict = ["teams": self.teams, "setWins":self.setWins, "date": dateString] as [String : Any]
        
        ref.updateChildValues(dict)
        ref = ref.child("sets")
        
        for set in sets{
            let setDict = ["redStats": set.redStats,"blueStats": set.blueStats, "redScore":set.redScore, "blueScore": set.blueScore] as [String : Any]
            ref.child(set.uid!).updateChildValues(setDict)
        
        }
        
        
        print("updating game in firebase")
    }
    
}


public class ASet: Codable
{
   
    var redStats = ["Ace": 0, "Kill": 0, "Block" :0, "Blue Err": 0, "Blue Serve Err":0]
    var blueStats = ["Ace": 0, "Kill": 0, "Block" :0, "Red Err": 0, "Red Serve Err":0]
    var redScore = 0
    var blueScore = 0
    var uid : String?
    
    
}




