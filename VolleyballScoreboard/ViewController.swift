//
//  ViewController.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 10/27/21.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {

    @IBOutlet var swipeOutlets: [UISwipeGestureRecognizer]!
    @IBOutlet var redStatsOutlet: [UIButton]!
    
    @IBOutlet var blueStatsOutlet: [UIButton]!
    
    
    @IBOutlet weak var redOutlet: UIButton!
    
    @IBOutlet weak var blueOutlet: UIButton!
    @IBOutlet weak var redKillOutlet: UIButton!
    
    var redScore = 0
    var blueScore = 0
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
        reset()
    }
    
    

    @IBAction func clearAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Warning!", message: "Are you sure you want to clear all data?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { (alert) in
            self.reset()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
//        redOutlet.setTitle("\(redScore)", for: .normal)
//        blueOutlet.setTitle("\(blueScore)", for: .normal)
        
        
    }
    
    func reset(){
        game = Game(redName: "Red Team", blueName: "Blue Team", currentDate: Date())
        
        redOutlet.setTitle("\(game.redScore)", for: .normal)
        blueOutlet.setTitle("\(game.blueScore)", for: .normal)
        
        for outlet in redStatsOutlet{
            var title = outlet.title(for: .normal)!
            for (key,value) in game.redStats{
                if title.contains(key){
                    outlet.setTitle("\(key)\n\(game.redStats[key]!)", for: .normal)
                }
            }
            
        }
        
        for outlet in blueStatsOutlet{
            var title = outlet.title(for: .normal)!
            for (key,value) in game.blueStats{
                if title.contains(key){
                    outlet.setTitle("\(key)\n\(game.blueStats[key]!)", for: .normal)
                }
            }
            
        }
    }
    
    
    @IBAction func redAction(_ sender: UIButton) {
        game.redScore += 1
        sender.setTitle("\(game.redScore)", for: .normal)
    }
    
    @IBAction func blueAction(_ sender: UIButton) {
        game.blueScore += 1
        sender.setTitle("\(game.blueScore)", for: .normal)
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
        for (key,value) in game.redStats
        {
            if let title = sender.title(for: .normal)
            {
                if title.contains(key)
                {
                    game.redStats[key]!+=1
                    sender.setTitle("\(key)\n\(game.redStats[key]!)", for: .normal)
                    increaseRedScore()
                }
            }
        }
    }
    
    @IBAction func blueStatAction(_ sender: UIButton) {
        print("blue stat happening")
          for (key,value) in game.blueStats
          {
              if let title = sender.title(for: .normal)
              {
                  if title.contains(key)
                  {
                      game.blueStats[key]!+=1
                      sender.setTitle("\(key)\n\(game.blueStats[key]!)", for: .normal)
                    increaseBlueScore()
                    
                  }
              }
          }
    }
    
    
   
    @IBAction func redAceSubtractAction(_ sender: UISwipeGestureRecognizer) {
        print("red Ace subtract")
        game.redStats["Ace"]! -= 1
        (sender.view as! UIButton).setTitle("Ace\n\(game.redStats["Ace"]!)", for: .normal)
        decreaseRedScore()
    }
    
    @IBAction func redKillSubtractAction(_ sender: UISwipeGestureRecognizer) {
        game.redStats["Kill"]! -= 1
        (sender.view as! UIButton).setTitle("Kill\n\(game.redStats["Kill"]!)", for: .normal)
        decreaseRedScore()
    }
    
    @IBAction func redBKLSubtractAction(_ sender: UISwipeGestureRecognizer) {
        game.redStats["Block"]! -= 1
        (sender.view as! UIButton).setTitle("Block\n\(game.redStats["Block"]!)", for: .normal)
        decreaseRedScore()
    }
    
    
    @IBAction func redOppErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        game.redStats["Blue Err"]! -= 1
        (sender.view as! UIButton).setTitle("Blue Err\n\(game.redStats["Blue Err"]!)", for: .normal)
       decreaseRedScore()
    }
    
    
    @IBAction func redOppServErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        game.redStats["Blue Serve Err"]! -= 1
        (sender.view as! UIButton).setTitle("Blue Serve Err\n\(game.redStats["Blue Serve Err"]!)", for: .normal)
        decreaseRedScore()
    }
    
    
    @IBAction func blueAceSubtractAction(_ sender: UISwipeGestureRecognizer) {
        print("blue Ace subtract")
        game.blueStats["Ace"]! -= 1
        (sender.view as! UIButton).setTitle("Ace\n\(game.blueStats["Ace"]!)", for: .normal)
        decreaseBlueScore()
    }
    
    @IBAction func blueKillSubtractAction(_ sender: UISwipeGestureRecognizer) {
        game.blueStats["Kill"]! -= 1
        (sender.view as! UIButton).setTitle("Kill\n\(game.blueStats["Kill"]!)", for: .normal)
        decreaseBlueScore()
        
    }
    
    
    @IBAction func blueBKLSubtractAction(_ sender: UISwipeGestureRecognizer) {
        game.blueStats["Block"]! -= 1
        (sender.view as! UIButton).setTitle("Block\n\(game.blueStats["Block"]!)", for: .normal)
        decreaseBlueScore()
    }
    
    @IBAction func blueOppErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        game.blueStats["Red Err"]! -= 1
        (sender.view as! UIButton).setTitle("Red Err\n\(game.blueStats["Red Err"]!)", for: .normal)
        decreaseBlueScore()
    }
    
    @IBAction func blueOppServErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        game.blueStats["Red Serve Err"]! -= 1
        (sender.view as! UIButton).setTitle("Red Serve Err\n\(game.blueStats["Red Serve Err"]!)", for: .normal)
        decreaseBlueScore()
    }
    
    func increaseRedScore(){
        game.redScore += 1
        redOutlet.setTitle("\(game.redScore)", for: .normal)
    }
    
    func increaseBlueScore(){
        game.blueScore += 1
        blueOutlet.setTitle("\(game.blueScore)", for: .normal)
    }
    
    func decreaseRedScore(){
        game.redScore -= 1
        redOutlet.setTitle("\(game.redScore)", for: .normal)
    }
    
    func decreaseBlueScore(){
        game.blueScore -= 1
        blueOutlet.setTitle("\(game.blueScore)", for: .normal)
    }
    
}

