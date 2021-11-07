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
    var publicGame : Bool = true
    
    
    
    init(teams: [String], date: Date, publicGame : Bool) {
        self.teams = teams
        self.date = date
        sets = [ASet]()
        self.publicGame = publicGame
        
    }
    
    init(key: String, dict: [String:Any] ) {
        teams = dict["teams"] as! [String]
        setWins = dict["setWins"] as! [Int]
        
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MM/dd/yy HH:MM"
        let dateString = dict["date"] as! String
        let timeString = dict["time"] as! String
        let fullDate = "\(dateString) \(timeString)"
        if let d = formatter1.date(from: fullDate){
        date = d

        }
        else{ date = Date()}
        
        sets = [ASet]()
        uid = key
        
        
    }
    
    func addSet(key: String, dict: [String:Any] ){
        sets.append(ASet(key: key, dict: dict))
    }
    
    func deleteFromFirebase(){
        if let ui = uid{
        Database.database().reference().child("games").child(ui).removeValue()
            
        print("Game has been removed from Firebase")
        }
        else{
            print("Error Deleting Game! Game not in Firebase")
        }
    }
    
    func saveToFirebase()
    {
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        let dateString = formatter1.string(from: date)
        
        formatter1.timeStyle = .short
        formatter1.dateStyle = .none
        let timeString = formatter1.string(from: date)
        
        let ref = Database.database().reference()
        let dict = ["teams": self.teams, "setWins":self.setWins, "date": dateString, "time": timeString, "publicGame": publicGame] as [String : Any]
       
        
        let gameRef = ref.child("games").childByAutoId()
        uid = gameRef.key
        gameRef.setValue(dict)
        
        for set in sets{
            let setDict = ["redStats": set.redStats,"blueStats": set.blueStats] as [String : Any]
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
        
        formatter1.timeStyle = .short
        formatter1.dateStyle = .none
        let timeString = formatter1.string(from: date)
        
        var ref = Database.database().reference().child("games").child(uid!)
        let dict = ["teams": self.teams, "setWins":self.setWins, "date": dateString, "time": timeString] as [String : Any]
        
        ref.updateChildValues(dict)
        ref = ref.child("sets")
        
        for set in sets{
            let setDict = ["redStats": set.redStats,"blueStats": set.blueStats] as [String : Any]
            ref.child(set.uid!).updateChildValues(setDict)
        
        }
        
        
        print("updating game in firebase")
    }
    
}


public class ASet: Codable
{
   
    var redStats = ["Ace": 0, "Kill": 0, "Block" :0, "Blue Err": 0, "Blue Serve Err":0, "redScore": 0]
    var blueStats = ["Ace": 0, "Kill": 0, "Block" :0, "Red Err": 0, "Red Serve Err":0, "blueScore": 0]
//    var redScore = 0
//    var blueScore = 0
    var uid : String?
    
    init()
    {
        
    }
    
    init(key: String, dict: [String:Any] ) {
        uid = key
        redStats = dict["redStats"] as! [String:Int]
        blueStats = dict["blueStats"] as! [String:Int]
//        redScore = dict["redScore"] as! Int
//        blueScore = dict["blueScore"] as! Int
        
     
      
    }
    
    
}




