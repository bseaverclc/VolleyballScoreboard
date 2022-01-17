//
//  HomeViewController.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 1/11/22.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getGamesFromFirebase()
        gameChangedInFirebase()
        gameDeletedInFirebase()
        
        if let items = UserDefaults.standard.data(forKey: "myGames") {
                        let decoder = JSONDecoder()
                        if let decoded = try? decoder.decode([Game].self, from: items) {
                            AppData.myGames = decoded
                        }
           
                }
        
        if let items = UserDefaults.standard.data(forKey: "myUIDs") {
                        let decoder = JSONDecoder()
                        if let decoded = try? decoder.decode([String].self, from: items) {
                            AppData.myUIDs = decoded
                        }
           
                }

    }
    

    @IBAction func newGameAction(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 1
    
    }
    
    func getGamesFromFirebase(){
        var ref: DatabaseReference!
        var handle1 : UInt! // These did not work!
        var handle2 : UInt!  // These did not work!

        ref = Database.database().reference()
        
        handle1 = ref.child("games").observe(.childAdded) { (snapshot) in
            print("childAdded")
            let uid = snapshot.key
            //print(uid)
           
            guard let dict = snapshot.value as? [String:Any]
            else{ print("Error")
                return
            }
            
            var addAth = true
            let g = Game(key: uid, dict: dict)
            for ga in AppData.allGames{
                if ga.uid == g.uid{
                    addAth = false
                }
            }
            if addAth{
            AppData.allGames.append(g)
            //print("Added Athlete to allAthletes \(AppData.allAthletes[Data.allAthletes.count-1].first) ")
            }
            for s in g.sets{
                //print(e.name)
            }
            handle2 = ref.child("games").child(uid).child("sets").observe(.childAdded) { (snapshot2) in
                guard let dict2 = snapshot2.value as? [String:Any]
                else{ print("Error")
                    return
                }
//                print("printing events")
//                print(dict2)
                var add = true
//                for s in g.sets{
//                    if dict2["name"] as! String == e.name && dict2["meetName"] as! String == e.meetName{
//                        add = false
//                    }
//                }
                if add{
                g.addSet(key: snapshot2.key, dict: dict2)
                //print("Added Event")
                //print("\(a.first) \(a.events[a.events.count-1].name)")
                }
                
            }
            ref.removeObserver(withHandle: handle2)
            //print("removing handle2")
               }
        
        ref.removeObserver(withHandle: handle1)
        //print("removing handle1")
        
        ref.removeAllObservers()
        
       
        for u in AppData.myUIDs{
            for g in AppData.allGames{
                if u == g.uid{
                    AppData.myGames.append(g)
                    print("Added a public game to my games")
                }
            }
        }
    }
    
    func gameChangedInFirebase(){
        
        
        var ref: DatabaseReference!

        ref = Database.database().reference()
        
        ref.child("games").observe(.childChanged) { (snapshot) in
            print("childchanged game changed on firebase")
            let uid = snapshot.key
            //print(uid)
           
            guard let dict = snapshot.value as? [String:Any]
            else{ print("Error in observe child Changed")
                return
            }
            
            
            let g = Game(key: uid, dict: dict)
            
            
//           // Data.allAthletes.append(a)
//           // ref.child("athletes").child(uid).child("events").
//            ref.child("athletes").child(uid).child("events").observe(.childRemoved, with: { (snapshot2) in
//                print("observe event removed from launchvc")
//            })
//
//
            ref.child("games").child(uid).child("sets").observe(.childAdded, with: { (snapshot2) in
  
                guard let dict2 = snapshot2.value as? [String:Any]
                else{ print("Error")
                    return
                }
                
                g.addSet(key: snapshot2.key, dict: dict2)
                print("added a set from firebase change")
            })
        
            
              // waits to happen when all things are read
            ref.child("games").child(uid).child("sets").observeSingleEvent(of: .value, with: { snapshot in
                   print("--load has completed and the last set was read--")
                for i in 0..<AppData.allGames.count{
                    if(AppData.allGames[i].uid == uid){
                        AppData.allGames[i] = g
                        print("addd changed game to AppData")
                        break;
                    }
                }
                    
                    for i in 0..<GamesViewController.filteredGames.count{
                        if(GamesViewController.filteredGames[i].uid == uid){
                            GamesViewController.filteredGames[i] = g
                            print("addd changed game to gamesVC filteredGames")
                            break;
                        }
                    }
                
//                if let ga = self.game{
//                if(g.uid == self.game.uid){
//                    self.game = g
//                    self.set = self.game.sets[self.setSegmentedControlOutlet.selectedSegmentIndex]
//                    self.updateScreenFromFirebase()
//                }
//                }
                
               })

            
        
       
            
        }
        
                
//                print("printing events")
//                print(dict2)
                
    }
    
    func gameDeletedInFirebase(){
        var ref: DatabaseReference!
        print("Removing game observed")
        ref = Database.database().reference()
        ref.child("games").observe(.childRemoved, with: { (snapshot) in
            print("Removing game observed from Array")
            for i in 0..<AppData.allGames.count{
                
                if AppData.allGames[i].uid == snapshot.key{
                    print("\(AppData.allGames[i].teams) has been removed")
                    AppData.allGames.remove(at: i)
                    break
                }
            }
            
        })
    }
    

}