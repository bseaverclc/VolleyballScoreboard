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
    static var myGames : [Game] = []
    static var canEdit = false
    static var selectedGame : Game?
    static var myUIDs: [String] = []
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var statsHorizontalStackView: UIStackView!
    @IBOutlet weak var redStackView: UIStackView!
    @IBOutlet weak var blueStackView: UIStackView!
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
    
//    var redScore = 0
//    var blueScore = 0
    var set : ASet!
    var game : Game!
    var first = true
    
    
    
 
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
        
        redTextFieldOutlet.delegate = self
        blueTextFieldOutlet.delegate = self
        setSwipeDirection()
        //newGame()
        //updateScreen()
        //reset()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("Game Did Appear")
        if let g = AppData.selectedGame{
            game = g
            set = game.sets[0]
            setSegmentedControlOutlet.selectedSegmentIndex = 0
            DispatchQueue.main.async {
                self.updateScreen()
            }
           
            
        }
        else{
            newGame()
        }
        
        if AppData.canEdit{
            redTextFieldOutlet.isEnabled = true
            blueTextFieldOutlet.isEnabled = true
        }
        else{
            redTextFieldOutlet.isEnabled = false
            blueTextFieldOutlet.isEnabled = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(AppData.myGames) {
                           UserDefaults.standard.set(encoded, forKey: "myGames")
                       }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        redTextFieldOutlet.resignFirstResponder()
        blueTextFieldOutlet.resignFirstResponder()
        game.teams[0] = redTextFieldOutlet.text!
        game.teams[1] = blueTextFieldOutlet.text!
        if game.publicGame{
        game.updateFirebase()
        }
        print("text field should return")
        return true
    }
    
    
    @IBAction func switchAction(_ sender: UIButton) {
        if let first = statsHorizontalStackView.subviews.first, let last = statsHorizontalStackView.subviews.last {
            statsHorizontalStackView.subviews.forEach { $0.removeFromSuperview() }
            statsHorizontalStackView.insertArrangedSubview(last, at: 0)
            statsHorizontalStackView.insertArrangedSubview(first, at: 1)
            statsHorizontalStackView.setNeedsLayout()
            statsHorizontalStackView.layoutIfNeeded()
          }
    }
    
    func newGame(){
        print("new Game being created")
        game = Game(teams: ["Red Team", "Blue Team"], date: Date(), publicGame: false)
        game.sets.append(ASet())
        game.sets.append(ASet())
        game.sets.append(ASet())
        set = game.sets[0]
        self.setSegmentedControlOutlet.selectedSegmentIndex = 0
        AppData.canEdit = true
        AppData.selectedGame = game
        
        let alert = UIAlertController(title: "Public or Private Game?", message: "Public Game everyone can view.  Private Game only you can view.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Public", style: .default, handler: { a in
            self.game.publicGame = true
            self.game.saveToFirebase()
            print("UId after saving to firebase: \(self.game.uid)")
            if let u = self.game.uid{
            AppData.myUIDs.append(u)
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(AppData.myUIDs) {
                                   UserDefaults.standard.set(encoded, forKey: "myUIDs")
                               }
            }
            else{
                print("Did not save uid to myUIDs")
            }
            AppData.myGames.append(self.game)
            
        }))
        alert.addAction(UIAlertAction(title: "Private", style: .default, handler: {a in
            AppData.myGames.append(self.game)
        }))
        present(alert, animated: true) {
            self.updateScreen()
        }
        
        
        
        //reset()
        
        //AppData.allGames.append(game)
        
        
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
        if AppData.canEdit{
            game.setWins[0] += 1
            sender.setTitle("\(game.setWins[0])", for: .normal)
        if game.publicGame{
        game.updateFirebase()
        }
        }
        
        
    }
    
    
    @IBAction func blueSetAddAction(_ sender: UIButton) {
        if AppData.canEdit{
            game.setWins[1] += 1
            sender.setTitle("\(game.setWins[1])", for: .normal)
        if game.publicGame{
        game.updateFirebase()
        }
        }
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
        
        redOutlet.setTitle("\(set.redStats["redScore"]!)", for: .normal)
        blueOutlet.setTitle("\(set.blueStats["blueScore"]!)", for: .normal)
        
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
        print("update Screen being called")
        redOutlet.setTitle("\(set.redStats["redScore"]!)", for: .normal)
        blueOutlet.setTitle("\(set.blueStats["blueScore"]!)", for: .normal)
        
        redSetOutlet.setTitle("\(game.setWins[0])", for: .normal)
        blueSetOutlet.setTitle("\(game.setWins[1])", for: .normal)
        
        redTextFieldOutlet.text = String(game.teams[0])
        blueTextFieldOutlet.text = String(game.teams[1])
        
        
        
        
        
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
        if game.publicGame{
        game.updateFirebase()
        }
    }
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        if AppData.canEdit{
        if redTextFieldOutlet.text != ""{
            game.teams[0] = redTextFieldOutlet.text!
            
        }
        if blueTextFieldOutlet.text != ""{
            game.teams[1] = blueTextFieldOutlet.text!
            
        }
            if game.publicGame{
        game.updateFirebase()
            }
        }
        
        
    }
    
    @IBAction func redAction(_ sender: UIButton) {
        if AppData.canEdit{
        set.redStats["redScore"]! += 1
        sender.setTitle("\(set.redStats["redScore"]!)", for: .normal)
        if game.publicGame{
        game.updateFirebase()
        }
        }
    }
    
    @IBAction func blueAction(_ sender: UIButton) {
        if AppData.canEdit{
        set.blueStats["blueScore"]! += 1
            sender.setTitle("\(set.blueStats["blueScore"]!)", for: .normal)
        if game.publicGame{
        game.updateFirebase()
        }
        }
    }
    

    
    
    @IBAction func redSubtractAction(_ sender: UISwipeGestureRecognizer) {
        print("swiping")
        if AppData.canEdit{
        decreaseRedScore()
        }
        
        
    }
    
    @IBAction func blueSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
       decreaseBlueScore()
        }
        
    }
    
    
  
    
    @IBAction func redStatAction(_ sender: UIButton) {
        if AppData.canEdit{
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
        
    }
    
    @IBAction func blueStatAction(_ sender: UIButton) {
        if AppData.canEdit{
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
    }
    
    
   
    @IBAction func redAceSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.redStats["Ace"]! -= 1
        (sender.view as! UIButton).setTitle("Ace\n\(set.redStats["Ace"]!)", for: .normal)
        decreaseRedScore()
        }
    }
    
    @IBAction func redKillSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.redStats["Kill"]! -= 1
        (sender.view as! UIButton).setTitle("Kill\n\(set.redStats["Kill"]!)", for: .normal)
        decreaseRedScore()
        }
    }
    
    @IBAction func redBKLSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.redStats["Block"]! -= 1
        (sender.view as! UIButton).setTitle("Block\n\(set.redStats["Block"]!)", for: .normal)
        decreaseRedScore()
        }
    }
    
    
    @IBAction func redOppErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.redStats["Blue Err"]! -= 1
        (sender.view as! UIButton).setTitle("Blue Err\n\(set.redStats["Blue Err"]!)", for: .normal)
       decreaseRedScore()
        }
    }
    
    
    @IBAction func redOppServErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.redStats["Blue Serve Err"]! -= 1
        (sender.view as! UIButton).setTitle("Blue Serve Err\n\(set.redStats["Blue Serve Err"]!)", for: .normal)
        decreaseRedScore()
        }
    }
    
    
    @IBAction func blueAceSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.blueStats["Ace"]! -= 1
        (sender.view as! UIButton).setTitle("Ace\n\(set.blueStats["Ace"]!)", for: .normal)
        decreaseBlueScore()
        }
    }
    
    @IBAction func blueKillSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.blueStats["Kill"]! -= 1
        (sender.view as! UIButton).setTitle("Kill\n\(set.blueStats["Kill"]!)", for: .normal)
        decreaseBlueScore()
        }
        
    }
    
    
    @IBAction func blueBKLSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.blueStats["Block"]! -= 1
        (sender.view as! UIButton).setTitle("Block\n\(set.blueStats["Block"]!)", for: .normal)
        decreaseBlueScore()
        }
    }
    
    @IBAction func blueOppErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.blueStats["Red Err"]! -= 1
        (sender.view as! UIButton).setTitle("Red Err\n\(set.blueStats["Red Err"]!)", for: .normal)
        decreaseBlueScore()
        }
    }
    
    @IBAction func blueOppServErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.blueStats["Red Serve Err"]! -= 1
        (sender.view as! UIButton).setTitle("Red Serve Err\n\(set.blueStats["Red Serve Err"]!)", for: .normal)
        decreaseBlueScore()
        }
    }
    
    func increaseRedScore(){
        set.redStats["redScore"]! += 1
        redOutlet.setTitle("\(set.redStats["redScore"]!)", for: .normal)
        if game.publicGame{
        game.updateFirebase()
        }
    }
    
    func increaseBlueScore(){
        set.blueStats["blueScore"]! += 1
        blueOutlet.setTitle("\(set.blueStats["blueScore"]!)", for: .normal)
        if game.publicGame{
        game.updateFirebase()
        }
    }
    
    func decreaseRedScore(){
        set.redStats["redScore"]! -= 1
        redOutlet.setTitle("\(set.redStats["redScore"]!)", for: .normal)
        if game.publicGame{
        game.updateFirebase()
        }
    }
    
    func decreaseBlueScore(){
        set.blueStats["blueScore"]! -= 1
        blueOutlet.setTitle("\(set.blueStats["blueScore"]!)", for: .normal)
        if game.publicGame{
        game.updateFirebase()
        }
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
        
        for u in AppData.myUIDs{
            for g in AppData.allGames{
                if u == g.uid{
                    AppData.myGames.append(g)
                }
            }
        }
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
                //print("Game \(i)Changed \(AppData.allGames[i].teams)")
                
            }
        
                
            }
            
        }
          
                
//                print("printing events")
//                print(dict2)
                
    }
    
}

