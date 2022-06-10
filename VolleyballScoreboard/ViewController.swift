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
    static var loadedData = false
}

class ViewController: UIViewController, UITextFieldDelegate {
    
   
   
    @IBOutlet weak var redAttackOutlet: UIButton!
    
    @IBOutlet weak var blueAttackOutlet: UIButton!
    
    @IBOutlet weak var redOneLabel: UILabel!
    @IBOutlet weak var redTwoLabel: UILabel!
    @IBOutlet weak var redThreeLabel: UILabel!
    
    @IBOutlet weak var blueOneLabel: UILabel!
    @IBOutlet weak var blueTwoLabel: UILabel!
    @IBOutlet weak var blueThreeLabel: UILabel!
    
   
    @IBOutlet weak var redHitPercentLabel: UILabel!
    @IBOutlet weak var redPassAvgLabel: UILabel!
    
    @IBOutlet weak var redEarnedPctLabel: UILabel!
    @IBOutlet weak var blueHitPercentLabel: UILabel!
    @IBOutlet weak var bluePassAvgLabel: UILabel!
    
    @IBOutlet weak var blueEarnedPctLabel: UILabel!
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
    var setNum = 1
    
    
    
 
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
    
    @IBAction func statsAction(_ sender: UIButton) {
        
        performSegue(withIdentifier: "statsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "historySegue"{
            let nvc = segue.destination as! HistoryViewController
            nvc.set = set
            nvc.setNum = setNum
            nvc.game = game
        }
        else{
        let nvc = segue.destination as! StatsViewController
        nvc.theGame = game
        }
    }
    
    @objc func functionName (notification: NSNotification){
        if let g = game{
            if let s = set{
                for ga in AppData.allGames{
                    if ga.uid == g.uid{
                        game = ga
                        for se in game.sets{
                            if se.uid == set.uid{
                                set = se;
                            }
                        }
                        break;
                    }
                }
                updateScreenFromFirebase()
                print("observer happening and updating screen")
            }
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        NotificationCenter.default.addObserver(self, selector: #selector(functionName), name: Notification.Name("notifyScreenChange"), object: nil)
        //getGamesFromFirebase()
        //gameChangedInFirebase()
       // gameDeletedInFirebase()
        
        
        
        
        
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
                print("public game")
                var alive = false
                for appGame in AppData.allGames{
                    if appGame.uid == g.uid{
                        print("found the game")
                        alive = true
                        game = appGame
                        AppData.selectedGame = game
                        set = game.sets[0]
                        print(set.redStats["redScore"]!)
                        setNum = 1
                        setSegmentedControlOutlet.selectedSegmentIndex = 0
                        DispatchQueue.main.async {
                            self.updateScreen()
                        }
                    }
                }
                if !alive{
                    var alert = UIAlertController(title: "Error", message: "Game has been deleted online.  Please delete from My Games", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { alert in
                        self.newGame()
                    }))
                    present(alert, animated: true, completion: nil)
                }
            }
            else{
                game = g
                set = game.sets[0]
                setSegmentedControlOutlet.selectedSegmentIndex = 0
                setNum = 1
                DispatchQueue.main.async {
                    self.updateScreen()
                }
                
                
            }
            
           
            
        }
        else{
            print("creating a newGame")
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
        print("view did disappear")
        if let theGame = game{
            if theGame.publicGame{
        for i in 0 ..< AppData.myGames.count{
            if AppData.myGames[i].uid == theGame.uid{
                AppData.myGames[i] = theGame
            }
        }
                for i in 0 ..< AppData.allGames.count{
                    if AppData.allGames[i].uid == theGame.uid{
                        AppData.allGames[i] = theGame
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
        setNum = 1
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
        
        let alert = UIAlertController(title: "Create a New Game?", message: "Public Game: Everyone can view\n  Private Game: Only you can view", preferredStyle: .alert)
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
                vc.selectedIndex = 2
        }))
        present(alert, animated: true) {
            
        }
        
        
        
        //reset()
        
        //AppData.allGames.append(game)
        
        
    }
    
    func chooseNumSets(){
        
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
                redAttackOutlet.setTitle("Attack\n  \(set.redAttack)", for: .normal)
                redOneLabel.text = "\(set.redOne)"
                redTwoLabel.text = "\(set.redTwo)"
                redThreeLabel.text = "\(set.redThree)"
                
                blueAttackOutlet.setTitle("Attack\n  \(set.blueAttack)", for: .normal)
                blueOneLabel.text = "\(set.blueOne)"
                blueTwoLabel.text = "\(set.blueTwo)"
                blueThreeLabel.text = "\(set.blueThree)"
                
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
                
                redAttackOutlet.setTitle("Attack\n  \(set.redAttack)", for: .normal)
                redOneLabel.text = "\(set.redOne)"
                redTwoLabel.text = "\(set.redTwo)"
                redThreeLabel.text = "\(set.redThree)"
                
                blueAttackOutlet.setTitle("Attack\n  \(set.blueAttack)", for: .normal)
                blueOneLabel.text = "\(set.blueOne)"
                blueTwoLabel.text = "\(set.blueTwo)"
                blueThreeLabel.text = "\(set.blueThree)"
                
                
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
    
    func redActionReal(sender: UIButton)
    {
        set.redStats["redScore"]! += 1
        sender.setTitle("\(set.redStats["redScore"]!)", for: .normal)
            
            let serve = set.serve;
            let redRotation = set.redRotation;
            let blueRotation = set.blueRotation;
           // increaseRedScore()
            var point = Point(serve: serve, redRotation: redRotation, blueRotation: blueRotation, who: "red", why: "", score: "\(set.redStats["redScore"]!)-\(set.blueStats["blueScore"]!)")
            if game.publicGame{
            set.addPoint(point: point )
            }
            else{
                set.pointHistory.append(point)
            }
            
            set.redRotationPlusMinus[set.redRotation] += 1
            set.blueRotationPlusMinus[set.blueRotation] -= 1
            if set.serve != "red"
            {
                set.serve = "red"
                set.redRotation = (set.redRotation + 1)
                if set.redRotation == 6{
                    set.redRotation = 0
                }
            }
            
            
            updatePercents()
        if game.publicGame{
        game.updateFirebase()
        }
    }
    
    @IBAction func redAction(_ sender: UIButton) {
        if AppData.canEdit{
            
            if set.blueStats["blueScore"]! == 0 && set.redStats["redScore"]! == 0{
                setFirstServeNoStats(from: sender, who: "red")
            }
            else{
                redActionReal(sender: sender)
            }
            
            
        
        }
    }
    
    func blueActionReal(sender: UIButton){
        set.blueStats["blueScore"]! += 1
            sender.setTitle("\(set.blueStats["blueScore"]!)", for: .normal)
            
            let serve = set.serve;
            let redRotation = set.redRotation;
            let blueRotation = set.blueRotation;
          //increaseBlueScore()
            set.addPoint(point: Point(serve: serve, redRotation: redRotation, blueRotation: blueRotation, who: "blue", why: "", score: "\(set.redStats["redScore"]!)-\(set.blueStats["blueScore"]!)"))
            
            set.blueRotationPlusMinus[set.blueRotation] += 1
            set.redRotationPlusMinus[set.redRotation] -= 1
            if set.serve != "blue"
            {
                set.serve = "blue"
                set.blueRotation = (set.blueRotation + 1)
                if set.blueRotation == 6{
                    set.blueRotation = 0
                }
            }
            
            updatePercents()
        if game.publicGame{
        game.updateFirebase()
        }
    }
    
    
    @IBAction func blueAction(_ sender: UIButton) {
        if AppData.canEdit{
            
            if set.blueStats["blueScore"]! == 0 && set.redStats["redScore"]! == 0{
                setFirstServeNoStats(from: sender, who: "blue")
            }
            else{
                blueActionReal(sender: sender)
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
    
    
    func redStatActionReal(sender: UIButton){
        for (key,value) in set.redStats
        {
            if let title = sender.title(for: .normal)
            {
                if title.contains(key)
                {
                    set.redStats[key]!+=1
                    if key == "Kill"{
                        set.redAttack = set.redAttack + 1
                        redAttackOutlet.setTitle("Attack\n  \(set.redAttack)", for: .normal)
                    }
                    if key == "Opponent Attack Err"{
                        set.blueAttack = set.blueAttack + 1
                        blueAttackOutlet.setTitle("Attack\n  \(set.blueAttack)", for: .normal)
                    }
                    sender.setTitle("\(key)\n\(set.redStats[key]!)", for: .normal)
                    let serve = set.serve;
                    let redRotation = set.redRotation;
                    let blueRotation = set.blueRotation;
                    increaseRedScore()
                    var point = Point(serve: serve, redRotation: redRotation, blueRotation: blueRotation, who: "red", why: key, score: "\(set.redStats["redScore"]!)-\(set.blueStats["blueScore"]!)")
                    if game.publicGame{
                    set.addPoint(point: point )
                    }
                    else{
                        set.pointHistory.append(point)
                    }
                    
                }
            }
        }
            updatePercents()
            if game.publicGame{
            game.updateFirebase()
                
            }
    }
    
    @IBAction func redStatAction(_ sender: UIButton) {
        if AppData.canEdit{
            if set.blueStats["blueScore"]! == 0 && set.redStats["redScore"] == 0{
                setFirstServe(from: sender, who: "red")
            }
            else{
                redStatActionReal(sender: sender)
            }
        
        }
        
    }
    
    @IBAction func blueStatAction(_ sender: UIButton) {
        if AppData.canEdit{
            if set.blueStats["blueScore"]! == 0 && set.redStats["redScore"] == 0{
                setFirstServe(from: sender, who: "blue")
            }
            else{
                blueStatActionReal(sender: sender)
            }
          
            
        }
    }
    
    func blueStatActionReal(sender: UIButton){
        for (key,value) in set.blueStats
        {
            if let title = sender.title(for: .normal)
            {
                if title.contains(key)
                {
                    if key == "Kill"{
                        set.blueAttack = set.blueAttack + 1
                        blueAttackOutlet.setTitle("Attack\n  \(set.blueAttack)", for: .normal)
                    }
                    if key == "Opponent Attack Err"{
                        set.redAttack = set.redAttack + 1
                        redAttackOutlet.setTitle("Attack\n  \(set.redAttack)", for: .normal)
                    }
                    
                    set.blueStats[key]!+=1
                    sender.setTitle("\(key)\n\(set.blueStats[key]!)", for: .normal)
                    let serve = set.serve;
                    let redRotation = set.redRotation;
                    let blueRotation = set.blueRotation;
                  increaseBlueScore()
                    set.addPoint(point: Point(serve: serve, redRotation: redRotation, blueRotation: blueRotation, who: "blue", why: key, score: "\(set.redStats["redScore"]!)-\(set.blueStats["blueScore"]!)"))
                  
                }
            }
        }
          updatePercents()
          if game.publicGame{
          game.updateFirebase()
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
        increaseRedScoreReal()
        
    }
    
    func increaseBlueScore(){
        increaseBlueScoreReal()
       
    }
    
    func setFirstServeNoStats(from: UIButton, who: String){
        let alert = UIAlertController(title: "Who served first?", message: "", preferredStyle: .alert)
        var red = "red"
        var blue = "blue"
        if redTextFieldOutlet.text!.count != 0{
            red = redTextFieldOutlet.text!
        }
        if blueTextFieldOutlet.text!.count != 0{
            blue = blueTextFieldOutlet.text!
        }
        alert.addAction(UIAlertAction(title: red, style: .default, handler: { alert in
            self.set.serve = "red"
            if who == "red"{
                self.redActionReal(sender: from)
            }
            else{
                self.blueActionReal(sender: from)
            }
        }))
        alert.addAction(UIAlertAction(title: blue, style: .default, handler: { alert in
            self.set.serve = "blue"
            if who == "red"{
                self.redActionReal(sender: from)
            }
            else{
                self.blueActionReal(sender: from)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func setFirstServe(from: UIButton, who : String){
        let alert = UIAlertController(title: "Who served first?", message: "", preferredStyle: .alert)
        var red = "red"
        var blue = "blue"
        if redTextFieldOutlet.text!.count != 0{
            red = redTextFieldOutlet.text!
        }
        if blueTextFieldOutlet.text!.count != 0{
            blue = blueTextFieldOutlet.text!
        }
        alert.addAction(UIAlertAction(title: red, style: .default, handler: { alert in
            self.set.serve = "red"
            if who == "red"{
            self.redStatActionReal(sender: from)
            }
            else{
                self.blueStatActionReal(sender: from)
            }
        }))
        alert.addAction(UIAlertAction(title: blue, style: .default, handler: { alert in
            self.set.serve = "blue"
            if who == "red"{
            self.redStatActionReal(sender: from)
            }
            else{
                self.blueStatActionReal(sender: from)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func increaseRedScoreReal(){
        set.redStats["redScore"]! += 1
        set.redRotationPlusMinus[set.redRotation] += 1
        set.blueRotationPlusMinus[set.blueRotation] -= 1
        if set.serve != "red"
        {
            set.serve = "red"
            set.redRotation = (set.redRotation + 1)
            if set.redRotation == 6{
                set.redRotation = 0
            }
        }
        redOutlet.setTitle("\(set.redStats["redScore"]!)", for: .normal)
        updatePercents()
        if game.publicGame{
        game.updateFirebase()
        }
    }
    
    func increaseBlueScoreReal(){
        set.blueStats["blueScore"]! += 1
        set.blueRotationPlusMinus[set.blueRotation] += 1
        set.redRotationPlusMinus[set.redRotation] -= 1
        if set.serve != "blue"
        {
            set.serve = "blue"
            set.blueRotation = (set.blueRotation + 1)
            if set.blueRotation == 6{
                set.blueRotation = 0
            }
        }
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
        setNum = sender.selectedSegmentIndex + 1
       // print(set.redStats)
        updateScreen()
        
    }
    
    func updatePercents(){
        if set.redAttack != 0{
            var redPercent = Double(Int((Double(set.redStats["Kill"]! - set.blueStats["Opponent Attack Err"]!)/Double(set.redAttack))*1000))/1000.0
            //var redPercentString = String(format: "%.000f", redPercent)
            redHitPercentLabel.text = "\(redPercent)"
            
        }
        else{
            redHitPercentLabel.text = "0.000"
        }
        
        if set.blueAttack != 0{
            var bluePercent = Double(Int((Double(set.blueStats["Kill"]! - set.redStats["Opponent Attack Err"]!)/Double(set.blueAttack))*1000))/1000.0
            //var redPercentString = String(format: "%.000f", redPercent)
            blueHitPercentLabel.text = "\(bluePercent)"
            
        }
        else{
            blueHitPercentLabel.text = "0.000"
        }
        
        var redPasses = set.blueStats["Ace"]! + set.redOne + set.redTwo + set.redThree
        var redPassTotal = set.redOne + 2*set.redTwo + 3*set.redThree
        if redPasses != 0{
            var redAvg = Double(Int((Double(redPassTotal)/Double(redPasses))*10))/10.0
            redPassAvgLabel.text = "\(redAvg)"
        }
        else{
            redPassAvgLabel.text = "0.0"
        }
        
        var bluePasses = set.redStats["Ace"]! + set.blueOne + set.blueTwo + set.blueThree
        var bluePassTotal = set.blueOne + 2*set.blueTwo + 3*set.blueThree
        if bluePasses != 0{
            var blueAvg = Double(Int((Double(bluePassTotal)/Double(bluePasses))*10))/10.0
            bluePassAvgLabel.text = "\(blueAvg)"
        }
        else{
            bluePassAvgLabel.text = "0.0"
        }
        
        
        
        
       if set.redStats["redScore"]! != 0{
//            redAcePct.text = "\(Int(round(Double(set.redStats["Ace"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
//            redKillPct.text = "\(Int(round(Double(set.redStats["Kill"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
//            redBlockPct.text = "\(Int(round(Double(set.redStats["Block"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
//            redErrorPct.text = "\(Int(round(Double(set.redStats["Opponent Err"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
//            redSvErrorPct.text = "\(Int(round(Double(set.redStats["Opponent Serve Err"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
           redEarnedPctLabel.text = "\(Int(round(Double(set.redStats["Ace"]!)/Double(set.redStats["redScore"]!)*100.0 + Double(set.redStats["Kill"]!)/Double(set.redStats["redScore"]!)*100.0 + Double(set.redStats["Block"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
//            redUnearnedPct.text = "\(Int(round(Double(set.redStats["Opponent Err"]!)/Double(set.redStats["redScore"]!)*100.0 + Double(set.redStats["Opponent Serve Err"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
        }
        else{
//            redAcePct.text = "0%"
//            redKillPct.text = "0%"
//            redBlockPct.text = "0%"
//            redErrorPct.text = "0%"
//            redSvErrorPct.text = "0%"
            redEarnedPctLabel.text = "0%"
//            redUnearnedPct.text = "0%"
       }
        
//        
//        
        if set.blueStats["blueScore"]! != 0{
//            blueActPct.text = "\(Int(round(Double(set.blueStats["Ace"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
//            blueKillPct.text = "\(Int(round(Double(set.blueStats["Kill"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
//            blueBlockPct.text = "\(Int(round(Double(set.blueStats["Block"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
//            blueErrorPct.text = "\(Int(round(Double(set.blueStats["Opponent Err"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
//            blueSvErrorPct.text = "\(Int(round(Double(set.blueStats["Opponent Serve Err"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
           blueEarnedPctLabel.text = "\(Int(round(Double(set.blueStats["Ace"]!)/Double(set.blueStats["blueScore"]!)*100.0 + Double(set.blueStats["Kill"]!)/Double(set.blueStats["blueScore"]!)*100.0 + Double(set.blueStats["Block"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
//            blueUnearnedPct.text = "\(Int(round(Double(set.blueStats["Opponent Err"]!)/Double(set.blueStats["blueScore"]!)*100.0 + Double(set.blueStats["Opponent Serve Err"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
//            
        }
       else{
//            blueActPct.text = "0%"
//            blueKillPct.text = "0%"
//            blueBlockPct.text = "0%"
//            blueErrorPct.text = "0%"
//            blueSvErrorPct.text = "0%"
            blueEarnedPctLabel.text = "0%"
//            blueUnearnedPct.text = "0%"
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
                
                //var theSet2 = ASet(key: snapshot2.key, dict: dict2)
                var theSet = g.addSet(key: snapshot2.key, dict: dict2)
                print("added a set from firebase change")
                
                ref.child("games").child(uid).child("sets").child(snapshot2.key).child("pointHistory").observe(.childAdded) { snapshot3 in
                    guard let dict3 = snapshot3.value as? [String: Any]
                    else{print("Error reading pointHistory Change from Firebase")
                        return
                    }
                    theSet.addPoint(key: snapshot3.key, dict: dict3)
                    print("Added a point from gameChangedFirebase from ViewController")
                    
                    
                    
                }
                
                ref.child("games").child(uid).child("sets").child(snapshot2.key).child("pointHistory").observeSingleEvent(of: .value, with: { snapshot in
                       print("--load has completed and the last point was read--")
                    //g.addSet(set: theSet)
                    for i in 0..<AppData.allGames.count{
                        if(AppData.allGames[i].uid == uid){
                            AppData.allGames[i] = g
                            
                            print("addd changed game to AppData")
                           // print("Who just won the point \(AppData.allGames[i].sets[0].pointHistory.last!.why)")
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
    
    func gameChangedInFirebase2(){
        
        
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
                    self.setNum = self.setSegmentedControlOutlet.selectedSegmentIndex + 1
                    self.updateScreenFromFirebase()
                }
                }
                
               })

            
        
       
            
        }
        
                
//                print("printing events")
//                print(dict2)
                
    }
    
    
    @IBAction func undoAction(_ sender: Any) {
        if AppData.canEdit{
        if let point = set.pointHistory.last{
            set.serve = point.serve
            set.blueRotation = point.blueRotation
            set.redRotation = point.redRotation
            if point.who == "red"{
                
                for (key,value) in set.redStats{
                    if key == point.why{
                        set.redStats[key]! -= 1
                        if key == "Opponent Attack Err"{
                            set.blueAttack = set.blueAttack - 1
                        }
                        if key == "Kill"{
                            set.redAttack = set.redAttack - 1
                        }
                    }
                }
                decreaseRedScore()
                
                set.redRotationPlusMinus[set.redRotation] -= 1
                set.blueRotationPlusMinus[set.blueRotation] += 1
                
            }
            if point.who == "blue"{
                
                for (key,value) in set.blueStats{
                    if key == point.why{
                        set.blueStats[key]! -= 1
                        if key == "Opponent Attack Err"{
                            set.redAttack = set.redAttack - 1
                        }
                        if key == "Kill"{
                            set.blueAttack = set.blueAttack - 1
                        }
                    }
                }
                decreaseBlueScore()
                set.redRotationPlusMinus[set.redRotation] += 1
                set.blueRotationPlusMinus[set.blueRotation] -= 1
                
            }
            if let guid = game.uid{
            set.deletePointFromFirebase(gameUid: guid, euid: point.uid)
            }
            else{
            set.pointHistory.removeLast()
            }
            updateScreen()
            
        }
    }
    }
    
    
    @IBAction func redAttackAction(_ sender: UIButton) {
        print("redAttackAction")
        set.redAttack = set.redAttack + 1
        
        redAttackOutlet.setTitle("Attack\n  \(set.redAttack)", for: .normal)
        updatePercents()
    }
    
    
    @IBAction func blueAttackAction(_ sender: UIButton) {
        print("blueAttackAction")
        set.blueAttack = set.blueAttack + 1
        
        blueAttackOutlet.setTitle("Attack\n  \(set.blueAttack)", for: .normal)
        updatePercents()
    }
    
    
    @IBAction func swipeRedAttackAction(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .down{
            set.redAttack = set.redAttack - 1
            
            redAttackOutlet.setTitle("Attack\n  \(set.redAttack)", for: .normal)
            updatePercents()
        }
    }
    
    @IBAction func swipeBlueAttackAction(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .down{
            set.blueAttack = set.blueAttack - 1
            
            blueAttackOutlet.setTitle("Attack\n  \(set.blueAttack)", for: .normal)
            updatePercents()
        }
    }
    
    
    @IBAction func redOneAction(_ sender: UIButton) {
        set.redOne = set.redOne + 1
        redOneLabel.text = "\(set.redOne)"
        updatePercents()
    }
    
    @IBAction func redTwoAction(_ sender: UIButton) {
        set.redTwo = set.redTwo + 1
        redTwoLabel.text = "\(set.redTwo)"
        updatePercents()
    }
    
    @IBAction func redThreeAction(_ sender: UIButton) {
        set.redThree = set.redThree + 1
        redThreeLabel.text = "\(set.redThree)"
        updatePercents()
    }
    
    @IBAction func blueOneAction(_ sender: UIButton) {
        set.blueOne = set.blueOne + 1
        blueOneLabel.text = "\(set.blueOne)"
        updatePercents()
    }
    
    @IBAction func blueTwoAction(_ sender: UIButton) {
        set.blueTwo = set.blueTwo + 1
        blueTwoLabel.text = "\(set.blueTwo)"
        updatePercents()
    }
    
    @IBAction func blueThreeAction(_ sender: UIButton) {
        set.blueThree = set.blueThree + 1
        blueThreeLabel.text = "\(set.blueThree)"
        updatePercents()
    }
    
    @IBAction func swipeRedOne(_ sender: UISwipeGestureRecognizer) {
        set.redOne = set.redOne - 1
        redOneLabel.text = "\(set.redOne)"
        updatePercents()
    }
    
    @IBAction func swipeRedTwo(_ sender: UISwipeGestureRecognizer) {
        set.redTwo = set.redTwo - 1
        redTwoLabel.text = "\(set.redTwo)"
        updatePercents()
    }
    
    @IBAction func swipeRedThree(_ sender: UISwipeGestureRecognizer) {
        set.redThree = set.redThree - 1
        redThreeLabel.text = "\(set.redThree)"
        updatePercents()
    }
    
    @IBAction func swipeBlueOne(_ sender: UISwipeGestureRecognizer) {
        set.blueOne = set.blueOne - 1
        blueOneLabel.text = "\(set.blueOne)"
        updatePercents()
    }
    
    @IBAction func swipeBlueTwo(_ sender: UISwipeGestureRecognizer) {
        set.blueTwo = set.blueTwo - 1
        blueTwoLabel.text = "\(set.blueTwo)"
        updatePercents()
    }
    
    @IBAction func swipeBlueThree(_ sender: UISwipeGestureRecognizer) {
        set.blueThree = set.blueThree - 1
        blueThreeLabel.text = "\(set.blueThree)"
        updatePercents()
    }
    
    
}

