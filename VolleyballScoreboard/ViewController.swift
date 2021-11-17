//
//  ViewController.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 10/27/21.
//
// ****New Download from xcode to go back to last working copy *******

import UIKit
import AudioToolbox
import Firebase

@available(iOS 14.0, *)
extension ViewController: UIColorPickerViewControllerDelegate {
    
    //  Called once you have finished picking the color.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        if AppData.selectedColorButton == "red"{
        for button in redStatsOutlet{
            button.backgroundColor = viewController.selectedColor
        }
        
        redSetOutlet.backgroundColor = viewController.selectedColor
        
        redOutlet.backgroundColor = viewController.selectedColor
        }
        else{
            for button in blueStatsOutlet{
                button.backgroundColor = viewController.selectedColor
            }
            
            blueSetOutlet.backgroundColor = viewController.selectedColor
            
            blueOutlet.backgroundColor = viewController.selectedColor
        }
        
            
        
    }
    
    //  Called on every color selection done in the picker.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            //self.view.backgroundColor = viewController.selectedColor
    }
}


class AppData{
    static var allGames : [Game] = []
    static var myGames : [Game] = []
    static var canEdit = false
    static var selectedGame : Game?
    static var myUIDs: [String] = []
    static var selectedColorButton = "red"
    static var canDelete = false
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var redAcePct: UILabel!
    @IBOutlet weak var redKillPct: UILabel!
    @IBOutlet weak var redBlockPct: UILabel!
    @IBOutlet weak var redErrorPct: UILabel!
    @IBOutlet weak var redSvErrorPct: UILabel!
    
    @IBOutlet weak var blueActPct: UILabel!
    @IBOutlet weak var blueKillPct: UILabel!
    @IBOutlet weak var blueBlockPct: UILabel!
    @IBOutlet weak var blueErrorPct: UILabel!
    @IBOutlet weak var blueSvErrorPct: UILabel!
    
    
    @IBOutlet weak var redEarnedPct: UILabel!
    @IBOutlet weak var redUnearnedPct: UILabel!
    @IBOutlet weak var blueUnearnedPct: UILabel!
    @IBOutlet weak var blueEarnedPct: UILabel!
    
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
        
        redTextFieldOutlet.delegate = self
        blueTextFieldOutlet.delegate = self
        setSwipeDirection()
        //newGame()
        //updateScreen()
        //reset()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("Game Did Appear")
        if let g = AppData.selectedGame {
            if g.publicGame{
                for appGame in AppData.allGames{
                    if appGame.uid == g.uid{
                        game = appGame
                        AppData.selectedGame = game
                        set = game.sets[0]
                        setSegmentedControlOutlet.selectedSegmentIndex = 0
                        DispatchQueue.main.async {
                            self.updateScreen()
                        }
                    }
                }
            }
            else{
                game = g
                set = game.sets[0]
                setSegmentedControlOutlet.selectedSegmentIndex = 0
                DispatchQueue.main.async {
                    self.updateScreen()
                }
                
                
            }
            
           
            
        }
        else{
            game = nil
            set = nil
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
        if let theGame = game{
            if theGame.publicGame{
        for i in 0 ..< AppData.myGames.count{
            if AppData.myGames[i].uid == theGame.uid{
                AppData.myGames[i] = theGame
            }
        }
            AppData.selectedGame = theGame
        }
        }
        // save myGames to userdefaults when you exit
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
    
    
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        print("tapped")
        if redTextFieldOutlet.isFirstResponder || blueTextFieldOutlet.isFirstResponder{
            redTextFieldOutlet.resignFirstResponder()
            blueTextFieldOutlet.resignFirstResponder()
            game.teams[0] = redTextFieldOutlet.text!
            game.teams[1] = blueTextFieldOutlet.text!
            if game.publicGame{
            game.updateFirebase()
            }
                print("got out of textfield")
            }
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
    
    func createGame(){
        print("new Game being created")
        game = Game(teams: ["", ""], date: Date(), publicGame: false)
        game.sets.append(ASet())
        game.sets.append(ASet())
        game.sets.append(ASet())
        set = game.sets[0]
        self.setSegmentedControlOutlet.selectedSegmentIndex = 0
        AppData.canEdit = true
        AppData.selectedGame = game
        redTextFieldOutlet.isEnabled = true
        blueTextFieldOutlet.isEnabled = true
        self.updateScreen()
    }
    
    func newGame(){
        if let theGame = game{
            if theGame.publicGame{
        for i in 0 ..< AppData.myGames.count{
            if AppData.myGames[i].uid == theGame.uid{
                AppData.myGames[i] = theGame
            }
        }
            AppData.selectedGame = theGame
        }
        }
        // save myGames to userdefaults when you exit
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(AppData.myGames) {
                           UserDefaults.standard.set(encoded, forKey: "myGames")
                       }
        
        let alert = UIAlertController(title: "Create a New Game?", message: "Public Game: Everyone can view but only you can edit\n  Private Game: Only you can view and edit", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Create Public Game", style: .default, handler: { a in
            self.createGame()
            self.game.publicGame = true
            AppData.canEdit = true
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
        alert.addAction(UIAlertAction(title: "Create Private Game", style: .default, handler: {a in
            
            self.createGame()
            self.game.publicGame = false
            AppData.canEdit = true
            AppData.myGames.append(self.game)
        }))
        alert.addAction(UIAlertAction(title: "View Public Games", style: .destructive, handler: { a in
            let vc = self.tabBarController!
                vc.selectedIndex = 1
        }))
        present(alert, animated: true) {
            
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
//        if AppData.canEdit{
//            game.setWins[0] += 1
//            sender.setTitle("\(game.setWins[0])", for: .normal)
//        if game.publicGame{
//        game.updateFirebase()
//        }
//        }
        
        AppData.selectedColorButton = "red"
        if #available(iOS 14.0, *) {
            showColorPicker()
        } else {
            let alert = UIAlertController(title: "Sorry", message: "Color Picker only available on ios 14.0 or later", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        
        
        
    }
    
    @available(iOS 14.0, *)
    func showColorPicker(){
        let picker = UIColorPickerViewController()
        

        // Setting the Initial Color of the Picker
        picker.selectedColor = UIColor.white

        // Setting Delegate
        picker.delegate = self

        // Presenting the Color Picker
        self.present(picker, animated: true, completion: nil)
    }
    
    
    
    @IBAction func blueSetAddAction(_ sender: UIButton) {
//        if AppData.canEdit{
//            game.setWins[1] += 1
//            sender.setTitle("\(game.setWins[1])", for: .normal)
//        if game.publicGame{
//        game.updateFirebase()
//        }
//        }
        
        AppData.selectedColorButton = "blue"
        if #available(iOS 14.0, *) {
            showColorPicker()
        } else {
            let alert = UIAlertController(title: "Sorry", message: "Color Picker only available on ios 14.0 or later", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    

    @IBAction func newGameAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Warning!", message: "Are you sure you want to start a new game?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "New", style: .default, handler: { (alert) in
            self.newGame()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
//        redOutlet.setTitle("\(redScore)", for: .normal)
//        blueOutlet.setTitle("\(blueScore)", for: .normal)
        
        
    }
    
    func reset(){
       // set = ASet()
        
        redOutlet.setTitle("\(set.redStats["redScore"]!)", for: .normal)
        blueOutlet.setTitle("\(set.blueStats["blueScore"]!)", for: .normal)
        
       // redSetOutlet.setTitle("\(game.setWins[0])", for: .normal)
       // blueSetOutlet.setTitle("\(game.setWins[1])", for: .normal)
        
        
        
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
    
    func updateScreenFromFirebase(){
        print("update Screen from firebase being called")
        if let s = set{
            if let g = game{
                print("update Screen from FB there is a set and game")
                redOutlet.setTitle("\(set.redStats["redScore"]!)", for: .normal)
                blueOutlet.setTitle("\(set.blueStats["blueScore"]!)", for: .normal)
                
                //redSetOutlet.setTitle("\(game.setWins[0])", for: .normal)
              //  blueSetOutlet.setTitle("\(game.setWins[1])", for: .normal)
                
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
     
               updatePercents()
            }
        }
    
    }
    
    func updateScreen(){
        print("update Screen being called")
        if let s = set{
            if let g = game{
                redOutlet.setTitle("\(set.redStats["redScore"]!)", for: .normal)
                blueOutlet.setTitle("\(set.blueStats["blueScore"]!)", for: .normal)
                
//                redSetOutlet.setTitle("\(game.setWins[0])", for: .normal)
//                blueSetOutlet.setTitle("\(game.setWins[1])", for: .normal)
                
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
       updatePercents()
        if game.publicGame{
        game.updateFirebase()
        }
                
            }
        }
    }
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        var errorMessage = "You don't have edit/save rights"
        var errorTitle = "Fail!"
        if AppData.canEdit{
            if game.publicGame{
        game.updateFirebase()
                errorTitle = "Success!"
                errorMessage = "Game has been saved"
                let alert = UIAlertController(title: "Success!", message: "Game has been saved", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                
            }
            else{
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(AppData.myGames) {
                                   UserDefaults.standard.set(encoded, forKey: "myGames")
                    errorTitle = "Success!"
                    errorMessage = "Game has been saved"
                               }
                
            }
            
        }
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func redAction(_ sender: UIButton) {
        if AppData.canEdit{
        set.redStats["redScore"]! += 1
        sender.setTitle("\(set.redStats["redScore"]!)", for: .normal)
            updatePercents()
        if game.publicGame{
        game.updateFirebase()
        }
        }
    }
    
    @IBAction func blueAction(_ sender: UIButton) {
        if AppData.canEdit{
        set.blueStats["blueScore"]! += 1
            sender.setTitle("\(set.blueStats["blueScore"]!)", for: .normal)
            updatePercents()
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
        if game.publicGame{
        game.updateFirebase()
        }
        
        
    }
    
    @IBAction func blueSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
       decreaseBlueScore()
        }
        if game.publicGame{
        game.updateFirebase()
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
            updatePercents()
            if game.publicGame{
            game.updateFirebase()
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
            updatePercents()
            if game.publicGame{
            game.updateFirebase()
            }
            
        }
    }
    
    
   
    @IBAction func redAceSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
            if set.redStats["Ace"]! > 0{
        set.redStats["Ace"]! -= 1
        (sender.view as! UIButton).setTitle("Ace\n\(set.redStats["Ace"]!)", for: .normal)
        decreaseRedScore()
        }
        }
    }
    
    @IBAction func redKillSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
            if set.redStats["Kill"]! > 0{
        set.redStats["Kill"]! -= 1
        (sender.view as! UIButton).setTitle("Kill\n\(set.redStats["Kill"]!)", for: .normal)
        decreaseRedScore()
        }
        }
            
    }
    
    @IBAction func redBKLSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
            if set.redStats["Block"]! > 0{
        set.redStats["Block"]! -= 1
        (sender.view as! UIButton).setTitle("Block\n\(set.redStats["Block"]!)", for: .normal)
        decreaseRedScore()
        }
        }
    }
    
    
    @IBAction func redOppErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
            if set.redStats["Opponent Err"]! > 0{
        set.redStats["Opponent Err"]! -= 1
        (sender.view as! UIButton).setTitle("Opponent Err\n\(set.redStats["Opponent Err"]!)", for: .normal)
       decreaseRedScore()
        }
        }
    }
    
    
    @IBAction func redOppServErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
            if  set.redStats["Opponent Serve Err"]! > 0{
        set.redStats["Opponent Serve Err"]! -= 1
        (sender.view as! UIButton).setTitle("Opponent Serve Err\n\(set.redStats["Opponent Serve Err"]!)", for: .normal)
        decreaseRedScore()
        }
        }
    }
    
    
    @IBAction func blueAceSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
            if set.blueStats["Ace"]! > 0{
        set.blueStats["Ace"]! -= 1
        (sender.view as! UIButton).setTitle("Ace\n\(set.blueStats["Ace"]!)", for: .normal)
        decreaseBlueScore()
        }
        }
    }
    
    @IBAction func blueKillSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
            if set.blueStats["Kill"]! > 0{
        set.blueStats["Kill"]! -= 1
        (sender.view as! UIButton).setTitle("Kill\n\(set.blueStats["Kill"]!)", for: .normal)
        decreaseBlueScore()
        }
        }
        
    }
    
    
    @IBAction func blueBKLSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
            if set.blueStats["Block"]! > 0{
        set.blueStats["Block"]! -= 1
        (sender.view as! UIButton).setTitle("Block\n\(set.blueStats["Block"]!)", for: .normal)
        decreaseBlueScore()
        }
        }
    }
    
    @IBAction func blueOppErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
            if set.blueStats["Opponent Err"]! > 0{
        set.blueStats["Opponent Err"]! -= 1
        (sender.view as! UIButton).setTitle("Opponent Err\n\(set.blueStats["Opponent Err"]!)", for: .normal)
        decreaseBlueScore()
        }
        }
    }
    
    @IBAction func blueOppServErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
            if set.blueStats["Opponent Serve Err"]! > 0{
        set.blueStats["Opponent Serve Err"]! -= 1
        (sender.view as! UIButton).setTitle("Opponent Serve Err\n\(set.blueStats["Opponent Serve Err"]!)", for: .normal)
        decreaseBlueScore()
        }
        }
    }
    
    func increaseRedScore(){
        set.redStats["redScore"]! += 1
        redOutlet.setTitle("\(set.redStats["redScore"]!)", for: .normal)
        updatePercents()
        if game.publicGame{
        game.updateFirebase()
        }
    }
    
    func increaseBlueScore(){
        set.blueStats["blueScore"]! += 1
        blueOutlet.setTitle("\(set.blueStats["blueScore"]!)", for: .normal)
        updatePercents()
        if game.publicGame{
        game.updateFirebase()
        }
    }
    
    func decreaseRedScore(){
        if set.redStats["redScore"]! > 0{
        set.redStats["redScore"]! -= 1
        redOutlet.setTitle("\(set.redStats["redScore"]!)", for: .normal)
            updatePercents()
        if game.publicGame{
        game.updateFirebase()
        }
        }
    }
    
    func decreaseBlueScore(){
        if set.blueStats["blueScore"]! > 0{
        set.blueStats["blueScore"]! -= 1
        blueOutlet.setTitle("\(set.blueStats["blueScore"]!)", for: .normal)
            updatePercents()
        if game.publicGame{
        game.updateFirebase()
        }
        }
    }
    
    
    @IBAction func setChooserAction(_ sender: UISegmentedControl) {
        
        set = game.sets[sender.selectedSegmentIndex]
        print(set.redStats)
        updateScreen()
        
    }
    
    func updatePercents(){
        if set.redStats["redScore"]! != 0{
            redAcePct.text = "\(Int(round(Double(set.redStats["Ace"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
            redKillPct.text = "\(Int(round(Double(set.redStats["Kill"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
            redBlockPct.text = "\(Int(round(Double(set.redStats["Block"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
            redErrorPct.text = "\(Int(round(Double(set.redStats["Opponent Err"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
            redSvErrorPct.text = "\(Int(round(Double(set.redStats["Opponent Serve Err"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
            redEarnedPct.text = "\(Int(round(Double(set.redStats["Ace"]!)/Double(set.redStats["redScore"]!)*100.0 + Double(set.redStats["Kill"]!)/Double(set.redStats["redScore"]!)*100.0 + Double(set.redStats["Block"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
            redUnearnedPct.text = "\(Int(round(Double(set.redStats["Opponent Err"]!)/Double(set.redStats["redScore"]!)*100.0 + Double(set.redStats["Opponent Serve Err"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
        }
        else{
            redAcePct.text = "0%"
            redKillPct.text = "0%"
            redBlockPct.text = "0%"
            redErrorPct.text = "0%"
            redSvErrorPct.text = "0%"
            redEarnedPct.text = "0%"
            redUnearnedPct.text = "0%"
        }
        
        
        if set.blueStats["blueScore"]! != 0{
            blueActPct.text = "\(Int(round(Double(set.blueStats["Ace"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
            blueKillPct.text = "\(Int(round(Double(set.blueStats["Kill"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
            blueBlockPct.text = "\(Int(round(Double(set.blueStats["Block"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
            blueErrorPct.text = "\(Int(round(Double(set.blueStats["Opponent Err"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
            blueSvErrorPct.text = "\(Int(round(Double(set.blueStats["Opponent Serve Err"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
            blueEarnedPct.text = "\(Int(round(Double(set.blueStats["Ace"]!)/Double(set.blueStats["blueScore"]!)*100.0 + Double(set.blueStats["Kill"]!)/Double(set.blueStats["blueScore"]!)*100.0 + Double(set.blueStats["Block"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
            blueUnearnedPct.text = "\(Int(round(Double(set.blueStats["Opponent Err"]!)/Double(set.blueStats["blueScore"]!)*100.0 + Double(set.blueStats["Opponent Serve Err"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
            
        }
        else{
            blueActPct.text = "0%"
            blueKillPct.text = "0%"
            blueBlockPct.text = "0%"
            blueErrorPct.text = "0%"
            blueSvErrorPct.text = "0%"
            blueEarnedPct.text = "0%"
            blueUnearnedPct.text = "0%"
        }
        
        
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
                
                if let ga = self.game{
                if(g.uid == self.game.uid){
                    self.game = g
                    self.set = self.game.sets[self.setSegmentedControlOutlet.selectedSegmentIndex]
                    self.updateScreenFromFirebase()
                }
                }
                
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

