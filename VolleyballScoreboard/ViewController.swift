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

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

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
        AppData.redColor = viewController.selectedColor
        }
        else{
            for button in blueStatsOutlet{
                button.backgroundColor = viewController.selectedColor
            }
            
            blueSetOutlet.backgroundColor = viewController.selectedColor
            blueOutlet.backgroundColor = viewController.selectedColor
            AppData.blueColor = viewController.selectedColor
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
    static var redColor = UIColor.systemRed
    static var blueColor = UIColor.systemBlue
}

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var redTableView: UITableView!
    
    
   
    @IBOutlet weak var redServeReceiveConstraints: NSLayoutConstraint!
    @IBOutlet weak var redServeReceiveLabelConstraints: NSLayoutConstraint!
    
  
    @IBOutlet weak var blueServeReceiveStackConstraints: NSLayoutConstraint!
    @IBOutlet weak var blueServeReceiveLabelConstraints: NSLayoutConstraint!
    
    
    @IBOutlet weak var blueErrorsConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var redAttackOutlet: UIButton!
    
    @IBOutlet weak var blueAttackOutlet: UIButton!
    
    @IBOutlet weak var redOneLabel: UILabel!
    @IBOutlet weak var redTwoLabel: UILabel!
    @IBOutlet weak var redThreeLabel: UILabel!
    
    @IBOutlet weak var blueOneLabel: UILabel!
    @IBOutlet weak var blueTwoLabel: UILabel!
    @IBOutlet weak var blueThreeLabel: UILabel!
    
   
    @IBOutlet weak var redHitTextLabel: UILabel!
    @IBOutlet weak var redHitPercentLabel: UILabel!
    
    @IBOutlet weak var redPassTextLabel: UILabel!
    @IBOutlet weak var redPassAvgLabel: UILabel!
    
    @IBOutlet weak var redEarnedPctLabel: UILabel!
    
    @IBOutlet weak var blueHitTextLabel: UILabel!
    @IBOutlet weak var blueHitPercentLabel: UILabel!
    
    @IBOutlet weak var bluePassTextLabel: UILabel!
    @IBOutlet weak var bluePassAvgLabel: UILabel!
    
    @IBOutlet weak var blueEarnedPctLabel: UILabel!
    @IBOutlet weak var statsHorizontalStackView: UIStackView!
    @IBOutlet weak var redStackView: UIStackView!
    @IBOutlet weak var blueStackView: UIStackView!
    var ref: DatabaseReference!

    @IBOutlet var swipeOutlets: [UISwipeGestureRecognizer]!
    @IBOutlet var redStatsOutlet: [UIButton]!

    @IBOutlet weak var redAttackErrLabelOutlet: UILabel!
    
    @IBOutlet weak var redServeErrLabelOutlet: UILabel!
    @IBOutlet weak var redOtherErrLabelOutlet: UILabel!
    
    @IBOutlet var blueStatsOutlet: [UIButton]!
    @IBOutlet weak var blueAttackErrLabelOutlet: UILabel!
    @IBOutlet weak var blueServeErrLabelOutlet: UILabel!
    @IBOutlet weak var blueOtherErrLabelOutlet: UILabel!
    
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
    
    var switched = false
    
    
    
 
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
        redTableView.delegate = self
        redTableView.dataSource = self
        
        for button in redStatsOutlet{

            button.titleLabel?.adjustsFontForContentSizeCategory = true
            button.titleLabel?.numberOfLines = 3
            button.titleLabel?.lineBreakMode = .byTruncatingMiddle
            

        }
        
        
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
        for button in redStatsOutlet{

            button.titleLabel?.adjustsFontForContentSizeCategory = true
            if button.tag >= 3{
            button.titleLabel?.layer.opacity = 0.0
            }

        }
        for button in blueStatsOutlet{

            button.titleLabel?.adjustsFontForContentSizeCategory = true
            

        }
        
        if let g = AppData.selectedGame {
            if let gt = g.type{
                if gt == 0{
                    fullStats()
                }
                else{
                    simpleStats()
                }
            }
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
           fullStats()
        }
        
        if AppData.canEdit{
            redTextFieldOutlet.isEnabled = true
            blueTextFieldOutlet.isEnabled = true
        }
        else{
            redTextFieldOutlet.isEnabled = false
            blueTextFieldOutlet.isEnabled = false
        }
      
        
        redTableView.reloadData()
        scrollToBottom()
        
        
        
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
 
        if switched{
            switched = false
            var first = statsHorizontalStackView.subviews[0]
            var last = statsHorizontalStackView.subviews[1]
                print("switching sides back")
            
                statsHorizontalStackView.removeArrangedSubview(first)
                statsHorizontalStackView.removeArrangedSubview(last)
                statsHorizontalStackView.addArrangedSubview(first)
                statsHorizontalStackView.addArrangedSubview(last)
                //statsHorizontalStackView.setNeedsLayout()
                //statsHorizontalStackView.layoutIfNeeded()
        }
        else{
            switched = true
            var first = statsHorizontalStackView.subviews[0]
            var last = statsHorizontalStackView.subviews[1]
                print("switching sides")
            
                statsHorizontalStackView.removeArrangedSubview(first)
                statsHorizontalStackView.removeArrangedSubview(last)
                statsHorizontalStackView.addArrangedSubview(last)
                statsHorizontalStackView.addArrangedSubview(first)
                //statsHorizontalStackView.setNeedsLayout()
                //statsHorizontalStackView.layoutIfNeeded()
        }
        redTableView.reloadData()
        scrollToBottom()
    }
    
    func createGame(){
        print("new Game being created")
        game = Game(teams: ["", ""], date: Date(), publicGame: false)
        game.sets.append(ASet())
        game.sets.append(ASet())
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
           self.chooseStats()
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
            self.chooseStats()
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
    
    func chooseStats(){
        let alert2 = UIAlertController(title: "Stats", message: "Simple Stats or Full Stats?", preferredStyle: .alert)
        alert2.addAction(UIAlertAction(title: "Simple", style: .default, handler: { a in
            self.game.type = 1
            self.simpleStats()
            if self.game.publicGame{
                self.game.updateFirebase()
            }
            
        }))
        alert2.addAction(UIAlertAction(title: "Full", style: .default, handler: {a in
            
            self.game.type = 0
            self.fullStats()
            if self.game.publicGame{
                self.game.updateFirebase()
            }
        }))
        present(alert2, animated: true) {
            
        }
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

                
                // updates the labels on the red error buttons
                         for (key,value) in set.redStats{
                             if key.contains("Attack Err"){
                                 redAttackErrLabelOutlet.text = "\(value)"
                             }
                             if key.contains("Serve Err"){
                                 redServeErrLabelOutlet.text = "\(value)"
                             }
                             if key.contains("Opponent Err"){
                                 redOtherErrLabelOutlet.text = "\(value)"
                             }
                             
                         }
                
                // updates the red button titles
                for i in 0 ..< redStatsOutlet.count{
            var title = redStatsOutlet[i].title(for: .normal)!
            for (key,value) in set.redStats{
                if title.contains(key){
                    
                    redStatsOutlet[i].setTitle("\(key)\n\(set.redStats[key]!)", for: .normal)
                    
                }
            }
            
     
            
        }
                
                // updates the labels on the blue error buttons
                         for (key,value) in set.blueStats{
                             if key.contains("Attack Err"){
                                 blueAttackErrLabelOutlet.text = "\(value)"
                             }
                             if key.contains("Serve Err"){
                                 blueServeErrLabelOutlet.text = "\(value)"
                             }
                             if key.contains("Opponent Err"){
                                 blueOtherErrLabelOutlet.text = "\(value)"
                             }
                             
                         }
        
                
                // update blue button titles
        for outlet in blueStatsOutlet{
            var title = outlet.title(for: .normal)!
            for (key,value) in set.blueStats{
                if title.contains(key){
                    outlet.setTitle("\(key)\n\(set.blueStats[key]!)", for: .normal)
                }
            }
            
        }
                redAttackOutlet.setTitle("Attack\n    \(set.redAttack)", for: .normal)
                redOneLabel.text = "\(set.redOne)"
                redTwoLabel.text = "\(set.redTwo)"
                redThreeLabel.text = "\(set.redThree)"
                
                blueAttackOutlet.setTitle("Attack\n    \(set.blueAttack)", for: .normal)
                blueOneLabel.text = "\(set.blueOne)"
                blueTwoLabel.text = "\(set.blueTwo)"
                blueThreeLabel.text = "\(set.blueThree)"
                
               updatePercents()
                redTableView.reloadData()
                scrollToBottom()
                
                
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
                
       // updates the labels on the red error buttons
                for (key,value) in set.redStats{
                    if key.contains("Attack Err"){
                        redAttackErrLabelOutlet.text = "\(value)"
                    }
                    if key.contains("Serve Err"){
                        redServeErrLabelOutlet.text = "\(value)"
                    }
                    if key.contains("Opponent Err"){
                        redOtherErrLabelOutlet.text = "\(value)"
                    }
                    
                }
                
     // updates the titles on the red buttons
                for i in 0 ..< redStatsOutlet.count{
            var title = redStatsOutlet[i].title(for: .normal)!
            for (key,value) in set.redStats{
                if title.contains(key){

                    redStatsOutlet[i].setTitle("\(key)\n\(set.redStats[key]!)", for: .normal)
                    
                }
            }
            
     
            
        }
                
                // updates the labels on the blue error buttons
                         for (key,value) in set.blueStats{
                             if key.contains("Attack Err"){
                                 blueAttackErrLabelOutlet.text = "\(value)"
                             }
                             if key.contains("Serve Err"){
                                 blueServeErrLabelOutlet.text = "\(value)"
                             }
                             if key.contains("Opponent Err"){
                                 blueOtherErrLabelOutlet.text = "\(value)"
                             }
                             
                         }
        
                
                // updates the titles on the blue buttons
        for outlet in blueStatsOutlet{
            var title = outlet.title(for: .normal)!
            if title.contains("Opponent Attack Err"){
                outlet.setTitle("Opponent Attack Err\n0", for: .normal)
            }
            for (key,value) in set.blueStats{
               
                if title.contains(key){
                    outlet.setTitle("\(key)\n\(set.blueStats[key]!)", for: .normal)
                }
                
            }
            
        }
                
                redAttackOutlet.setTitle("Attack\n    \(set.redAttack)", for: .normal)
                redOneLabel.text = "\(set.redOne)"
                redTwoLabel.text = "\(set.redTwo)"
                redThreeLabel.text = "\(set.redThree)"
                
                blueAttackOutlet.setTitle("Attack\n    \(set.blueAttack)", for: .normal)
                blueOneLabel.text = "\(set.blueOne)"
                blueTwoLabel.text = "\(set.blueTwo)"
                blueThreeLabel.text = "\(set.blueThree)"
                
                
      updatePercents()
                redTableView.reloadData()
                scrollToBottom()
//        if game.publicGame{
//        game.updateFirebase()
//        }
                
            }
        }
    }
    
    
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        var errorMessage = "You don't have edit/save rights"
        var errorTitle = "Fail!"
        if AppData.canEdit{
            if game.publicGame{
               game.updateFirebase()
                
                for i in 0 ..< AppData.myGames.count{
                    if AppData.myGames[i].uid == game.uid{
                        AppData.myGames[i] = game
                    }
                }
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(AppData.myGames) {
                                   UserDefaults.standard.set(encoded, forKey: "myGames")
                }
 
                errorTitle = "Success!"
                errorMessage = "Game has been saved "
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
        highlightRedButton(button: sender)
        sender.setTitle("\(set.redStats["redScore"]!)", for: .normal)
            
            let serve = set.serve;
            let redRotation = set.redRotation;
            let blueRotation = set.blueRotation;
           // increaseRedScore()
        set.addPoint(point: Point(serve: serve, redRotation: redRotation, blueRotation: blueRotation, who: "red", why: "", score: "\(set.redStats["redScore"]!)-\(set.blueStats["blueScore"]!)"))
//            if game.publicGame{
//            set.addPoint(point: point )
//            }
//            else{
//                set.pointHistory.append(point)
//            }
            
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
            set.setUpdateFirebase(gameUid: game.uid!)
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
        highlightBlueButton(button: sender)
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
                    if key == "Block"{
                        set.blueAttack = set.blueAttack + 1
                        if let oae = set.redStats["Opponent Attack Err"]{
                            set.redStats["Opponent Attack Err"]! += 1
                        }
                        
                    }
                    sender.setTitle("\(key)\n\(set.redStats[key]!)", for: .normal)
                    highlightRedButton(button: sender)
                    let serve = set.serve;
                    let redRotation = set.redRotation;
                    let blueRotation = set.blueRotation;
                    increaseRedScore()
                    set.addPoint(point: Point(serve: serve, redRotation: redRotation, blueRotation: blueRotation, who: "red", why: key, score: "\(set.redStats["redScore"]!)-\(set.blueStats["blueScore"]!)"))
                    print("added a point from redStatActionReal")
                  
//                    if game.publicGame{
//                    set.addPoint(point: point )
//                    }
//                    else{
//                        set.pointHistory.append(point)
//                    }
                    
                }
            }
        }
        updatePercents()
        updateScreen()
            
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
                    if key == "Block"{
                        set.redAttack = set.redAttack + 1
                        if let oae = set.blueStats["Opponent Attack Err"]{
                            set.blueStats["Opponent Attack Err"]! += 1
                        }
                    }
                    
                    set.blueStats[key]!+=1
                    sender.setTitle("\(key)\n\(set.blueStats[key]!)", for: .normal)
                    highlightBlueButton(button: sender)
                    let serve = set.serve;
                    let redRotation = set.redRotation;
                    let blueRotation = set.blueRotation;
                    increaseBlueScore()
                    set.addPoint(point: Point(serve: serve, redRotation: redRotation, blueRotation: blueRotation, who: "blue", why: key, score: "\(set.redStats["redScore"]!)-\(set.blueStats["blueScore"]!)"))
                    
                  
                }
            }
        }
        updatePercents()
        updateScreen()
          
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
//        if game.publicGame{
//        game.updateFirebase()
//        }
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
//        if game.publicGame{
//        game.updateFirebase()
//        }
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
        if sender.selectedSegmentIndex < game.sets.count{
        set = game.sets[sender.selectedSegmentIndex]
        setNum = sender.selectedSegmentIndex + 1
       // print(set.redStats)
        updateScreen()
        }
        else{
            sender.selectedSegmentIndex = game.sets.count - 1
            set = game.sets[sender.selectedSegmentIndex]
            setNum = sender.selectedSegmentIndex + 1
            updateScreen()
            
        }
        
    }
    
    func updatePercents(){
        if set.redAttack != 0{
            if let attackErr = set.blueStats["Opponent Attack Err"]{
                //var redPercent = Double(Int((Double(set.redStats["Kill"]! - attackErr)/Double(set.redAttack))*1000))/1000.0
                var redPercent2 = (Double(set.redStats["Kill"]! - attackErr))/Double(set.redAttack)
                var redPercentString = String(format: "%.3f", redPercent2)
                redHitPercentLabel.text = "\(redPercentString)"
            }
            else{
                redHitPercentLabel.text = "NA"
            }
            
            
        }
        else{
            redHitPercentLabel.text = "0.000"
        }
        
        if set.blueAttack != 0{
            if let attackErr = set.redStats["Opponent Attack Err"]{
                //var bluePercent = Double(Int((Double(set.blueStats["Kill"]! - attackErr)/Double(set.blueAttack))*1000))/1000.0
                var bluePercent2 = Double(set.blueStats["Kill"]! - attackErr)/Double(set.blueAttack)
                var bluePercentString = String(format: "%.3f", bluePercent2)
                blueHitPercentLabel.text = "\(bluePercentString)"
            }
            else{
                blueHitPercentLabel.text = "NA"
            }
            
            
        }
        else{
            blueHitPercentLabel.text = "0.000"
        }
        
        var redPasses = set.blueStats["Ace"]! + set.redOne + set.redTwo + set.redThree
        var redPassTotal = set.redOne + 2*set.redTwo + 3*set.redThree
        if redPasses != 0{
            var redAvg = Double(Int((Double(redPassTotal)/Double(redPasses))*100))/100.0
            redPassAvgLabel.text = "\(redAvg)"
        }
        else{
            redPassAvgLabel.text = "0.0"
        }
        
        var bluePasses = set.redStats["Ace"]! + set.blueOne + set.blueTwo + set.blueThree
        var bluePassTotal = set.blueOne + 2*set.blueTwo + 3*set.blueThree
        if bluePasses != 0{
            var blueAvg = Double(Int((Double(bluePassTotal)/Double(bluePasses))*100))/100.0
            bluePassAvgLabel.text = "\(blueAvg)"
        }
        else{
            bluePassAvgLabel.text = "0.0"
        }
        
        
        
        
       if set.redStats["redScore"]! != 0{
           redEarnedPctLabel.text = "\(Int(round(Double(set.redStats["Ace"]!)/Double(set.redStats["redScore"]!)*100.0 + Double(set.redStats["Kill"]!)/Double(set.redStats["redScore"]!)*100.0 + Double(set.redStats["Block"]!)/Double(set.redStats["redScore"]!)*100.0)))%"

        }
        else{
            redEarnedPctLabel.text = "0%"
       }
        
       
        if set.blueStats["blueScore"]! != 0{

           blueEarnedPctLabel.text = "\(Int(round(Double(set.blueStats["Ace"]!)/Double(set.blueStats["blueScore"]!)*100.0 + Double(set.blueStats["Kill"]!)/Double(set.blueStats["blueScore"]!)*100.0 + Double(set.blueStats["Block"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
           
        }
       else{
            blueEarnedPctLabel.text = "0%"
        }
       
        
        
    }
    
    
  
    
    
    
    
    @IBAction func undoAction(_ sender: Any) {
        if AppData.canEdit{
        if let point = set.pointHistory.last{
            set.serve = point.serve
            set.blueRotation = point.blueRotation
            set.redRotation = point.redRotation
            print(point.who)
            if point.who == "red"{
                print("red who")
                for (key,value) in set.redStats{
                    if key == point.why{
                        set.redStats[key]! -= 1
                        for button in redStatsOutlet{
                            var title = button.title(for: .normal)!
                            if title.contains(key){
                                highlightRedButton(button: button)
                            }
                        }
                        if key == "Opponent Attack Err"{
                            set.blueAttack = set.blueAttack - 1
                        }
                        if key == "Kill"{
                            set.redAttack = set.redAttack - 1
                        }
                        if key == "Block"{
                            set.blueAttack -= 1
                            if let oae = set.redStats["Opponent Attack Err"]{
                                set.redStats["Opponent Attack Err"]! -= 1
                            }
                        }
                    }
                }
                
                //decrease red score
                if set.redStats["redScore"]! > 0{
                set.redStats["redScore"]! -= 1
                redOutlet.setTitle("\(set.redStats["redScore"]!)", for: .normal)
                }
                
                set.redRotationPlusMinus[set.redRotation] -= 1
                set.blueRotationPlusMinus[set.blueRotation] += 1
                
            }
            if point.who == "blue"{
                print("blue who")
                for (key,value) in set.blueStats{
                    if key == point.why{
                        set.blueStats[key]! -= 1
                        for button in blueStatsOutlet{
                            var title = button.title(for: .normal)!
                            if title.contains(key){
                                highlightBlueButton(button: button)
                            }
                        }
                        if key == "Opponent Attack Err"{
                            set.redAttack = set.redAttack - 1
                        }
                        if key == "Kill"{
                            set.blueAttack = set.blueAttack - 1
                        }
                        if key == "Block"{
                            set.redAttack -= 1
                            if let oae = set.blueStats["Opponent Attack Err"]{
                                set.blueStats["Opponent Attack Err"]! -= 1
                            }
                        }
                    }
                }
                
                if set.blueStats["blueScore"]! > 0{
                set.blueStats["blueScore"]! -= 1
                blueOutlet.setTitle("\(set.blueStats["blueScore"]!)", for: .normal)
                }
                set.redRotationPlusMinus[set.redRotation] += 1
                set.blueRotationPlusMinus[set.blueRotation] -= 1
                
            }
            
            updatePercents()
            updateScreen()
           
            if let guid = game.uid{
               //set.pointHistory.removeLast()
               
               set.deletePointFromFirebase(gameUid: guid, euid: point.uid)
                set.setUpdateFirebase(gameUid: guid)
                //game.updateFirebase()
                
                
            }
            else{
            set.pointHistory.removeLast()
            }
            
           
            
            
            
        }
    }
    }
    
    
    @IBAction func redAttackAction(_ sender: UIButton) {
        if AppData.canEdit{
        print("redAttackAction")
        highlightButton(button: sender)
        set.redAttack = set.redAttack + 1
        
        redAttackOutlet.setTitle("Attack\n    \(set.redAttack)", for: .normal)
        updatePercents()
        
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    
    @IBAction func blueAttackAction(_ sender: UIButton) {
        if AppData.canEdit{
        print("blueAttackAction")
        set.blueAttack = set.blueAttack + 1
        highlightButton(button: sender)
        blueAttackOutlet.setTitle("Attack\n    \(set.blueAttack)", for: .normal)
        updatePercents()
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    
    @IBAction func swipeRedAttackAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        if sender.direction == .down{
            set.redAttack = set.redAttack - 1
            
            redAttackOutlet.setTitle("Attack\n    \(set.redAttack)", for: .normal)
            updatePercents()
            if game.publicGame{
                game.updateFirebase()
            }
        }
        }
    }
    
    @IBAction func swipeBlueAttackAction(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        if sender.direction == .down{
            set.blueAttack = set.blueAttack - 1
            
            blueAttackOutlet.setTitle("Attack\n    \(set.blueAttack)", for: .normal)
            updatePercents()
            if game.publicGame{
                game.updateFirebase()
            }
        }
        }
    }
    
    
    @IBAction func redOneAction(_ sender: UIButton) {
        if AppData.canEdit{
        set.redOne = set.redOne + 1
        highlightButton(button: sender)
        redOneLabel.text = "\(set.redOne)"
        updatePercents()
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    @IBAction func redTwoAction(_ sender: UIButton) {
        if AppData.canEdit{
        set.redTwo = set.redTwo + 1
        highlightButton(button: sender)
        redTwoLabel.text = "\(set.redTwo)"
        updatePercents()
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    @IBAction func redThreeAction(_ sender: UIButton) {
        if AppData.canEdit{
        set.redThree = set.redThree + 1
        highlightButton(button: sender)
        redThreeLabel.text = "\(set.redThree)"
        updatePercents()
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    @IBAction func blueOneAction(_ sender: UIButton) {
        if AppData.canEdit{
        set.blueOne = set.blueOne + 1
        highlightButton(button: sender)
        blueOneLabel.text = "\(set.blueOne)"
        updatePercents()
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    @IBAction func blueTwoAction(_ sender: UIButton) {
        if AppData.canEdit{
        set.blueTwo = set.blueTwo + 1
        highlightButton(button: sender)
        blueTwoLabel.text = "\(set.blueTwo)"
        updatePercents()
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    @IBAction func blueThreeAction(_ sender: UIButton) {
        if AppData.canEdit{
        set.blueThree = set.blueThree + 1
        highlightButton(button: sender)
        blueThreeLabel.text = "\(set.blueThree)"
        updatePercents()
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    @IBAction func swipeRedOne(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.redOne = set.redOne - 1
        redOneLabel.text = "\(set.redOne)"
        updatePercents()
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    @IBAction func swipeRedTwo(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.redTwo = set.redTwo - 1
        redTwoLabel.text = "\(set.redTwo)"
        updatePercents()
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    @IBAction func swipeRedThree(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
 
        set.redThree = set.redThree - 1
        redThreeLabel.text = "\(set.redThree)"
        updatePercents()
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    @IBAction func swipeBlueOne(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.blueOne = set.blueOne - 1
        blueOneLabel.text = "\(set.blueOne)"
        updatePercents()
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    @IBAction func swipeBlueTwo(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.blueTwo = set.blueTwo - 1
        blueTwoLabel.text = "\(set.blueTwo)"
        updatePercents()
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    @IBAction func swipeBlueThree(_ sender: UISwipeGestureRecognizer) {
        if AppData.canEdit{
        set.blueThree = set.blueThree - 1
        blueThreeLabel.text = "\(set.blueThree)"
        updatePercents()
        if game.publicGame{
            game.updateFirebase()
        }
        }
    }
    
    func highlightRedButton(button: UIButton){
        print("calling highlightRedbutton")
       // var ogc = button.backgroundColor
        button.backgroundColor = UIColor.green
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            button.backgroundColor = AppData.redColor
            print("changing back to red color")
        }
    }
    
    func highlightBlueButton(button: UIButton){
        print("calling highlightBluebutton")
       // var ogc = button.backgroundColor
        button.backgroundColor = UIColor.green
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            button.backgroundColor = AppData.blueColor
            print("changing back to blue color")
        }
    }
    
    func highlightButton(button: UIButton){
        print("calling highlightbutton")
       // var ogc = button.backgroundColor
        button.backgroundColor = UIColor.green
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            button.backgroundColor = UIColor.systemYellow
            print("changing back to yellow color")
        }
    }
    
    func setMultiplier(constraint: inout NSLayoutConstraint, multiplier : CGFloat){
        let newConstraint = constraint.constraintWithMultiplier(multiplier)
        view.removeConstraint(constraint)
        view.addConstraint(newConstraint)
        //view.layoutIfNeeded()
        constraint = newConstraint
    }
    
    func simpleStats(){
     
        
        setMultiplier(constraint: &redServeReceiveConstraints, multiplier: 0.01)
        setMultiplier(constraint: &redServeReceiveLabelConstraints, multiplier: 0.01)
        setMultiplier(constraint: &blueServeReceiveStackConstraints, multiplier: 0.01)
        setMultiplier(constraint: &blueServeReceiveLabelConstraints, multiplier: 0.01)
        

       
        redOneLabel.isHidden = true
        redTwoLabel.isHidden = true
        redThreeLabel.isHidden = true
        blueOneLabel.isHidden = true
        blueTwoLabel.isHidden = true
        blueThreeLabel.isHidden = true
        redAttackOutlet.isHidden = true
        blueAttackOutlet.isHidden = true
        redHitTextLabel.isHidden = true
        redHitPercentLabel.isHidden = true
        blueHitTextLabel.isHidden = true
        blueHitPercentLabel.isHidden = true
        redPassTextLabel.isHidden = true
        redPassAvgLabel.isHidden = true
        bluePassTextLabel.isHidden = true
        bluePassAvgLabel.isHidden = true
        view.layoutIfNeeded()
    }
    
    func fullStats(){
        
        setMultiplier(constraint: &redServeReceiveLabelConstraints, multiplier: 0.09)
        setMultiplier(constraint: &redServeReceiveConstraints, multiplier: 0.37)
        
        setMultiplier(constraint: &blueServeReceiveLabelConstraints, multiplier: 0.09)
        setMultiplier(constraint: &blueServeReceiveStackConstraints, multiplier: 0.37)
        view.layoutIfNeeded()
       
        redOneLabel.isHidden = false
        redTwoLabel.isHidden = false
        redThreeLabel.isHidden = false
        blueOneLabel.isHidden = false
        blueTwoLabel.isHidden = false
        blueThreeLabel.isHidden = false
        redAttackOutlet.isHidden = false
        blueAttackOutlet.isHidden = false
        redHitTextLabel.isHidden = false
        redHitPercentLabel.isHidden = false
        blueHitTextLabel.isHidden = false
        blueHitPercentLabel.isHidden = false
        redPassTextLabel.isHidden = false
        redPassAvgLabel.isHidden = false
        bluePassTextLabel.isHidden = false
        bluePassAvgLabel.isHidden = false
        
    }
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = set{
           return set.pointHistory.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! HistoryCell
        cell.pointArrangement(switched: switched)
        cell.configure2(point: set.pointHistory[indexPath.row])
        
        
        return cell
    }
    
    func scrollToBottom(){
        if let s = set{
        if(s.pointHistory.count != 0)
            
        {
        let indexPath = IndexPath(item: s.pointHistory.count - 1, section: 0)
        redTableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
        }
        }
    }
    
    
    
}

