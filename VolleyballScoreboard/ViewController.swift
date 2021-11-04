//
//  ViewController.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 10/27/21.
//

import UIKit
import AudioToolbox
import Firebase


class AppData{
    static var allGames : [Game] = []
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    var ref: DatabaseReference!

    @IBOutlet var swipeOutlets: [UISwipeGestureRecognizer]!
    @IBOutlet var redStatsOutlet: [UIButton]!
    
    @IBOutlet var blueStatsOutlet: [UIButton]!
    
    @IBOutlet weak var setSegmentedControlOutlet: UISegmentedControl!
    
    @IBOutlet weak var redSetOutlet: UIButton!
    @IBOutlet weak var blueSetOutlet: UIButton!
    
    @IBOutlet weak var redTextFieldOutlet: UITextField!
    
    @IBOutlet weak var blueTextFieldOutlet: UITextField!
    @IBOutlet weak var redOutlet: UIButton!
    @IBOutlet weak var blueOutlet: UIButton!
    @IBOutlet weak var redKillOutlet: UIButton!
    
    var redScore = 0
    var blueScore = 0
    var set : ASet!
    var game : Game!
    
    
 
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        print("rotating phone")
        for outlet in swipeOutlets{
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight{
            
                outlet.direction = .left
                
            }
        else{
            outlet.direction = .down
        }
        
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        getGamesFromFirebase()
        gameChangedInFirebase()
        
        redTextFieldOutlet.delegate = self
        blueTextFieldOutlet.delegate = self
        setSwipeDirection()
        newGame()
        updateScreen()
        //reset()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        redTextFieldOutlet.resignFirstResponder()
        blueTextFieldOutlet.resignFirstResponder()
        game.teams[0] = redTextFieldOutlet.text!
        game.teams[1] = blueTextFieldOutlet.text!
        game.updateFirebase()
        print("text field should return")
        return true
    }
    
    func newGame(){
        print("new Game being created")
        game = Game(teams: ["Red Team", "Blue Team"], date: Date())
        game.sets.append(ASet())
        game.sets.append(ASet())
        game.sets.append(ASet())
        set = game.sets[0]
        self.setSegmentedControlOutlet.selectedSegmentIndex = 0
        reset()
        
        //AppData.allGames.append(game)
        game.saveToFirebase()
    }
    
    func setSwipeDirection(){
        for outlet in swipeOutlets{
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight{
                
                    outlet.direction = .left
                    
                }
            else{
                outlet.direction = .down
            }
            
        }
        
        for outlet in redStatsOutlet{
            outlet.titleLabel!.textAlignment = NSTextAlignment.center;
        }
        
        for outlet in blueStatsOutlet{
            outlet.titleLabel!.textAlignment = NSTextAlignment.center;
        }
    }
    
    @IBAction func redSetAddAction(_ sender: UIButton) {
        game.setWins[0] += 1
        sender.setTitle("\(game.setWins[0])", for: .normal)
        game.updateFirebase()
        
    }
    
    
    @IBAction func blueSetAddAction(_ sender: UIButton) {
        game.setWins[1] += 1
        sender.setTitle("\(game.setWins[1])", for: .normal)
        game.updateFirebase()
    }
    

    @IBAction func newGameAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Warning!", message: "Are you sure you want to start a new game?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "New", style: .destructive, handler: { (alert) in
            self.newGame()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
//        redOutlet.setTitle("\(redScore)", for: .normal)
//        blueOutlet.setTitle("\(blueScore)", for: .normal)
        
        
    }
    
    func reset(){
       // set = ASet()
        
        redOutlet.setTitle("\(set.redScore)", for: .normal)
        blueOutlet.setTitle("\(set.blueScore)", for: .normal)
        
        redSetOutlet.setTitle("\(game.setWins[0])", for: .normal)
        blueSetOutlet.setTitle("\(game.setWins[1])", for: .normal)
        
        
        
        for outlet in redStatsOutlet{
            var title = outlet.title(for: .normal)!
            for (key,value) in set.redStats{
                if title.contains(key){
                    outlet.setTitle("\(key)\n\(set.redStats[key]!)", for: .normal)
                }
            }
            
        }
        
        for outlet in blueStatsOutlet{
            var title = outlet.title(for: .normal)!
            for (key,value) in set.blueStats{
                if title.contains(key){
                    outlet.setTitle("\(key)\n\(set.blueStats[key]!)", for: .normal)
                }
            }
            
        }
    }
    
    func updateScreen(){
        print("update Screen being")
        redOutlet.setTitle("\(set.redScore)", for: .normal)
        blueOutlet.setTitle("\(set.blueScore)", for: .normal)
        
        redSetOutlet.setTitle("\(game.setWins[0])", for: .normal)
        blueSetOutlet.setTitle("\(game.setWins[1])", for: .normal)
        
        redTextFieldOutlet.text = game.teams[0]
        blueTextFieldOutlet.text = game.teams[1]
        
        
        
        
        
        for outlet in redStatsOutlet{
            var title = outlet.title(for: .normal)!
            for (key,value) in set.redStats{
                if title.contains(key){
                    outlet.setTitle("\(key)\n\(set.redStats[key]!)", for: .normal)
                }
            }
            
        }
        
        for outlet in blueStatsOutlet{
            var title = outlet.title(for: .normal)!
            for (key,value) in set.blueStats{
                if title.contains(key){
                    outlet.setTitle("\(key)\n\(set.blueStats[key]!)", for: .normal)
                }
            }
            
        }
        
        game.updateFirebase()
    }
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        if redTextFieldOutlet.text != ""{
            game.teams[0] = redTextFieldOutlet.text!
            
        }
        if blueTextFieldOutlet.text != ""{
            game.teams[1] = blueTextFieldOutlet.text!
            
        }
        game.updateFirebase()
        
        
    }
    
    @IBAction func redAction(_ sender: UIButton) {
        set.redScore += 1
        sender.setTitle("\(set.redScore)", for: .normal)
        game.updateFirebase()
    }
    
    @IBAction func blueAction(_ sender: UIButton) {
        set.blueScore += 1
        sender.setTitle("\(set.blueScore)", for: .normal)
        game.updateFirebase()
    }
    

    
    
    @IBAction func redSubtractAction(_ sender: UISwipeGestureRecognizer) {
        print("swiping")
        decreaseRedScore()
        
        
    }
    
    @IBAction func blueSubtractAction(_ sender: UISwipeGestureRecognizer) {
        
       decreaseBlueScore()
        
    }
    
    
  
    
    @IBAction func redStatAction(_ sender: UIButton) {
      print("red stat happening")
        for (key,value) in set.redStats
        {
            if let title = sender.title(for: .normal)
            {
                if title.contains(key)
                {
                    set.redStats[key]!+=1
                    sender.setTitle("\(key)\n\(set.redStats[key]!)", for: .normal)
                    increaseRedScore()
                }
            }
        }
        
    }
    
    @IBAction func blueStatAction(_ sender: UIButton) {
        print("blue stat happening")
          for (key,value) in set.blueStats
          {
              if let title = sender.title(for: .normal)
              {
                  if title.contains(key)
                  {
                      set.blueStats[key]!+=1
                      sender.setTitle("\(key)\n\(set.blueStats[key]!)", for: .normal)
                    increaseBlueScore()
                    
                  }
              }
          }
       
    }
    
    
   
    @IBAction func redAceSubtractAction(_ sender: UISwipeGestureRecognizer) {
        print("red Ace subtract")
        set.redStats["Ace"]! -= 1
        (sender.view as! UIButton).setTitle("Ace\n\(set.redStats["Ace"]!)", for: .normal)
        decreaseRedScore()
    }
    
    @IBAction func redKillSubtractAction(_ sender: UISwipeGestureRecognizer) {
        set.redStats["Kill"]! -= 1
        (sender.view as! UIButton).setTitle("Kill\n\(set.redStats["Kill"]!)", for: .normal)
        decreaseRedScore()
    }
    
    @IBAction func redBKLSubtractAction(_ sender: UISwipeGestureRecognizer) {
        set.redStats["Block"]! -= 1
        (sender.view as! UIButton).setTitle("Block\n\(set.redStats["Block"]!)", for: .normal)
        decreaseRedScore()
    }
    
    
    @IBAction func redOppErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        set.redStats["Blue Err"]! -= 1
        (sender.view as! UIButton).setTitle("Blue Err\n\(set.redStats["Blue Err"]!)", for: .normal)
       decreaseRedScore()
    }
    
    
    @IBAction func redOppServErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        set.redStats["Blue Serve Err"]! -= 1
        (sender.view as! UIButton).setTitle("Blue Serve Err\n\(set.redStats["Blue Serve Err"]!)", for: .normal)
        decreaseRedScore()
    }
    
    
    @IBAction func blueAceSubtractAction(_ sender: UISwipeGestureRecognizer) {
        print("blue Ace subtract")
        set.blueStats["Ace"]! -= 1
        (sender.view as! UIButton).setTitle("Ace\n\(set.blueStats["Ace"]!)", for: .normal)
        decreaseBlueScore()
    }
    
    @IBAction func blueKillSubtractAction(_ sender: UISwipeGestureRecognizer) {
        set.blueStats["Kill"]! -= 1
        (sender.view as! UIButton).setTitle("Kill\n\(set.blueStats["Kill"]!)", for: .normal)
        decreaseBlueScore()
        
    }
    
    
    @IBAction func blueBKLSubtractAction(_ sender: UISwipeGestureRecognizer) {
        set.blueStats["Block"]! -= 1
        (sender.view as! UIButton).setTitle("Block\n\(set.blueStats["Block"]!)", for: .normal)
        decreaseBlueScore()
    }
    
    @IBAction func blueOppErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        set.blueStats["Red Err"]! -= 1
        (sender.view as! UIButton).setTitle("Red Err\n\(set.blueStats["Red Err"]!)", for: .normal)
        decreaseBlueScore()
    }
    
    @IBAction func blueOppServErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        set.blueStats["Red Serve Err"]! -= 1
        (sender.view as! UIButton).setTitle("Red Serve Err\n\(set.blueStats["Red Serve Err"]!)", for: .normal)
        decreaseBlueScore()
    }
    
    func increaseRedScore(){
        set.redScore += 1
        redOutlet.setTitle("\(set.redScore)", for: .normal)
        game.updateFirebase()
    }
    
    func increaseBlueScore(){
        set.blueScore += 1
        blueOutlet.setTitle("\(set.blueScore)", for: .normal)
        game.updateFirebase()
    }
    
    func decreaseRedScore(){
        set.redScore -= 1
        redOutlet.setTitle("\(set.redScore)", for: .normal)
        game.updateFirebase()
    }
    
    func decreaseBlueScore(){
        set.blueScore -= 1
        blueOutlet.setTitle("\(set.blueScore)", for: .normal)
        game.updateFirebase()
    }
    
    
    @IBAction func setChooserAction(_ sender: UISegmentedControl) {
        
        set = game.sets[sender.selectedSegmentIndex]
        print(set.redStats)
        updateScreen()
    }
    
    
    func getGamesFromFirebase(){
        var ref: DatabaseReference!
        var handle1 : UInt! // These did not work!
        var handle2 : UInt!  // These did not work!

        ref = Database.database().reference()
        
        handle1 = ref.child("games").observe(.childAdded) { (snapshot) in
            //print("athlete observed")
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
    }
    
    func gameChangedInFirebase(){
        var ref: DatabaseReference!

        ref = Database.database().reference()
        
        ref.child("games").observe(.childChanged) { (snapshot) in
            //print("athlete observed2")
            let uid = snapshot.key
            //print(uid)
           
            guard let dict = snapshot.value as? [String:Any]
            else{ print("Error in observe child Changed")
                return
            }
            
            
            let g = Game(key: uid, dict: dict)
            print("\(g.teams) game just changed")
            
//           // Data.allAthletes.append(a)
//           // ref.child("athletes").child(uid).child("events").
//            ref.child("athletes").child(uid).child("events").observe(.childRemoved, with: { (snapshot2) in
//                print("observe event removed from launchvc")
//            })
//
//
            ref.child("games").child(uid).child("sets").observe(.childAdded, with: { (snapshot2) in
                //print("snapshot2 \(snapshot2)")



                guard let dict2 = snapshot2.value as? [String:Any]
                else{ print("Error")
                    return
                }
                
                g.addSet(key: snapshot2.key, dict: dict2)

//                var add = true
//                for s in a.events{
//                    if dict2["name"] as! String == e.name && dict2["meetName"] as! String == e.meetName{
//                        add = false
//                    }
//                }
//                if add{
//                a.addEvent(key: snapshot2.key, dict: dict2)
//                print("in changed event added")
//
//                }



            })
        
               
        
        for i in 0..<AppData.allGames.count{
            if(AppData.allGames[i].uid == uid){
                AppData.allGames[i] = g
                self.updateScreen()
                print("Game \(i)Changed \(AppData.allGames[i].teams)")
                
            }
        
                
            }
            
        }
          
                
//                print("printing events")
//                print(dict2)
                
    }
    
}

