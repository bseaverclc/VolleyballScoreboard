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
    var intDate: Int
    
    
    
    init(teams: [String], date: Date, publicGame : Bool) {
        self.teams = teams
        self.date = date
        sets = [ASet]()
        self.publicGame = publicGame
    

        // convert Date to TimeInterval (typealias for Double)
        let timeInterval = self.date.timeIntervalSince1970

        // convert to Integer
        intDate = Int(self.date.timeIntervalSince1970)
        //uid = ""
        
    }
    
    init(key: String, dict: [String:Any] ) {
        teams = dict["teams"] as! [String]
        setWins = dict["setWins"] as! [Int]
        
        if let inD = dict["intDate"] as? Int
        {
        intDate = inD
        date = Date(timeIntervalSince1970: TimeInterval(intDate))
        }
        else
        {
        
        let formatter1 = DateFormatter()
        
        //formatter1.locale = Locale(identifier: "en_US_POSIX")
        //formatter1.timeZone = .autoupdatingCurrent
        formatter1.dateFormat = "MM/dd/yy HH:mm aa"
        let dateString = dict["date"] as! String
        let timeString = dict["time"] as! String
        print("\(dateString) \(timeString)")
        let fullDate = "\(dateString) \(timeString)"
            
        if let d = formatter1.date(from: fullDate)
        {
        date = d
            intDate = Int(self.date.timeIntervalSince1970)


            let dateFormatter = DateFormatter()
            //dateFormatter.dateFormat = "MM/D/YY"
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short

            let convertedDate = dateFormatter.string(from: date)
            print(convertedDate)

        }
        else{
            print("Error Reading date")
            date = Date()
            intDate = Int(self.date.timeIntervalSince1970)

        }
        }
        
        sets = [ASet]()
        uid = key
        
        
    }
    
    func addSet(key: String, dict: [String:Any] ) -> ASet{
        let createdSet = ASet(key: key, dict: dict)
        sets.append(createdSet)
        return createdSet
    }
    
    func addSet(set: ASet){
        sets.append(set)
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
        let dict = ["teams": self.teams, "setWins":self.setWins, "date": dateString, "time": timeString, "publicGame": publicGame, "intDate": intDate] as [String : Any]
       
        
        let gameRef = ref.child("games").childByAutoId()
        uid = gameRef.key
        gameRef.setValue(dict)
        
        for set in sets{
            let setDict = ["redStats": set.redStats,"blueStats": set.blueStats, "serve": set.serve, "redRotation": set.redRotation, "blueRotation": set.blueRotation, "redRotationPlusMinus": set.redRotationPlusMinus, "blueRotationPlusMinus": set.blueRotationPlusMinus, "pointHistory": set.pointHistory ] as [String : Any]
            //let setDict = ["redStats": set.redStats,"blueStats": set.blueStats] as [String : Any]
            let setsID = gameRef.child("sets").childByAutoId()
            set.uid = setsID.key
            setsID.setValue(setDict)
            

            
            for point in set.pointHistory{
                let setDict = ["serve": point.serve, "redRotation": point.redRotation, "blueRotation": point.blueRotation, "who": point.who, "why": point.why, "score": point.score] as [String: Any]
                let pointRef = setsID.child("pointHistory").childByAutoId()
                point.uid = pointRef.key!
                pointRef.setValue(setDict)
                //ref.child(point.uid).updateChildValues(setDict)
            }
            
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
        let dict = ["teams": self.teams, "setWins":self.setWins, "date": dateString, "time": timeString, "intDate": intDate] as [String : Any]
        
        ref.updateChildValues(dict)
        ref = ref.child("sets")
        
        for set in sets{
            let setDict = ["redStats": set.redStats,"blueStats": set.blueStats, "serve": set.serve, "redRotation": set.redRotation, "blueRotation": set.blueRotation, "redRotationPlusMinus": set.redRotationPlusMinus, "blueRotationPlusMinus": set.blueRotationPlusMinus, "redAttack": set.redAttack, "redOne": set.redOne, "redTwo": set.redTwo, "redThree": set.redThree, "blueOne": set.blueOne, "blueTwo": set.blueTwo, "blueThree": set.blueThree] as [String: Any]
            ref.child(set.uid!).updateChildValues(setDict)
            
            
            for point in set.pointHistory{
                let pointDict = ["serve": point.serve, "redRotation": point.redRotation, "blueRotation": point.blueRotation, "who": point.who, "why": point.why, "score": point.score] as [String: Any]
                
                ref.child(set.uid!).child("pointHistory").child(point.uid).updateChildValues(pointDict)
            }
        
        }
        
      

        
        print("updating game in firebase")
    }
    
}


public class ASet: Codable
{
   
    var redStats = ["Ace": 0, "Kill": 0, "Block" :0, "Opponent Err": 0, "Opponent Serve Err":0, "redScore": 0, "Opponent Attack Err": 0]
    var blueStats = ["Ace": 0, "Kill": 0, "Block" :0, "Opponent Err": 0, "Opponent Serve Err":0, "blueScore":0, "Opponent Attack Err": 0]
   
//    var serve: String?
//    var redRotation: Int?
//    var blueRotation: Int?
//    var redRotationPlusMinus: [Int]?
//    var blueRotationPlusMinus : [Int]?
//    var pointHistory : [Point]?
//
//    var redScore : Int?
//    var blueScore : Int?
    
    var serve = "red"
    var redRotation = 0
    var blueRotation = 0
    var redRotationPlusMinus = [0,0,0,0,0,0]
    var blueRotationPlusMinus = [0,0,0,0,0,0]
    var pointHistory = [Point]()

    var redScore = 0
    var blueScore = 0
    
    var uid : String?
    
    var redAttack = 0
    var redOne = 0
    var redTwo = 0
    var redThree = 0
    
    var blueAttack = 0
    var blueOne = 0
    var blueTwo = 0
    var blueThree = 0
    
    
    init()
    {
//         serve = "red"
//         redRotation = 0
//         blueRotation = 0
//         redRotationPlusMinus = [0,0,0,0,0,0]
//         blueRotationPlusMinus = [0,0,0,0,0,0]
//         pointHistory = [Point]()
//
//         redScore = 0
//         blueScore = 0
    }
    
    init(key: String, dict: [String:Any] ) {
        uid = key
        redStats = dict["redStats"] as! [String:Int]
        blueStats = dict["blueStats"] as! [String:Int]
        if let s = dict["serve"] as? String{
            serve = s
        }
        if let rr = dict["redRotation"] as? Int{
            redRotation = rr
        }
        if let br = dict["blueRotation"] as? Int{
            blueRotation = br
        }
        if let rrpm = dict["redRotationPlusMinus"] as? [Int]{
            redRotationPlusMinus = rrpm
        }
        if let brpm = dict["blueRotationPlusMinus"] as? [Int]{
            blueRotationPlusMinus = brpm
        }
        if let ra = dict["redAttack"] as? Int{
            redAttack = ra
        }
        if let rone = dict["redOne"] as? Int{
            redOne = rone
        }
        if let rtwo = dict["redTwo"] as? Int{
            redTwo = rtwo
        }
        if let rthree = dict["redThree"] as? Int{
            redThree = rthree
        }
        if let ba = dict["blueAttack"] as? Int{
            blueAttack = ba
        }
        if let bone = dict["blueOne"] as? Int{
            blueOne = bone
        }
        if let btwo = dict["blueTwo"] as? Int{
            blueTwo = btwo
        }
        if let bthree = dict["blueThree"] as? Int{
            blueThree = bthree
        }
        
    
        
//        pointHistory = [Point]()
//
//        redScore = 0
//        blueScore = 0
//        if let ph = dict["pointHistory"] as? [Any]{
//            //pointHistory = ph as! [Point]
//            if let phd = ph as? [String: Any]{
//                for point in phd{
//                    
//                }
//            }
//            print("got point history from Firebase")
//        }
//        else{
//            print("making pointHistory from firebase did not work")
//        }
//        redScore = dict["redScore"] as! Int
//        blueScore = dict["blueScore"] as! Int
        
     
      
    }
    
    func addPoint(point: Point){
        
            
        pointHistory.append(point)
        if let ui = uid{
        let ref = Database.database().reference().child(ui)
        point.uid = ref.childByAutoId().key!
            print("added point with key \(point.uid)")
        }
        
            //updateFirebase()
        
        
    }
    
    func addPoint(key: String, dict: [String: Any]){
        pointHistory.append(Point(key: key, dict: dict))
    }
    
    func deletePointFromFirebase(gameUid: String, euid: String){
        if let uia = uid{
            pointHistory.removeLast()
            print("Trying to remove point \(euid)")
            Database.database().reference().child("games").child(gameUid).child("sets").child(uia).child("pointHistory").child(euid).removeValue()
            //print(ref)
        print("Point has been removed from Firebase")
            
        }
        else{
            print("Error Deleting Event! Event not in Firebase")
        }
    }
    
    
}




