//
//  ViewController.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 10/27/21.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var redOutlet: UIButton!
    
    @IBOutlet weak var blueOutlet: UIButton!
    @IBOutlet weak var redErrorOutlet: UIButton!
    @IBOutlet weak var blueErrorOutlet: UIButton!
    var redScore = 0
    var blueScore = 0
    var redError = 0
    var blueError = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func clearAction(_ sender: UIButton) {
        redScore = 0
        blueScore = 0
        redError = 0
        blueError = 0
        redOutlet.setTitle("\(redScore)", for: .normal)
        blueOutlet.setTitle("\(blueScore)", for: .normal)
        redErrorOutlet.setTitle("\(redError)", for: .normal)
        blueErrorOutlet.setTitle("\(blueError)", for: .normal)
        
    }
    
    
    @IBAction func redAction(_ sender: UIButton) {
        redScore += 1
        sender.setTitle("\(redScore)", for: .normal)
    }
    
    @IBAction func blueAction(_ sender: UIButton) {
        blueScore += 1
        sender.setTitle("\(blueScore)", for: .normal)
    }
    
    @IBAction func redErrorAction(_ sender: UIButton) {
        redError += 1
        sender.setTitle("\(redError)", for: .normal)
    }
    
    @IBAction func blueErrorAction(_ sender: UIButton) {
        blueError += 1
        sender.setTitle("\(blueError)", for: .normal)
    }
    
    @IBAction func redSubtractAction(_ sender: UISwipeGestureRecognizer) {
        print("swiping")
        redScore -= 1
        redOutlet.setTitle("\(redScore)", for: .normal)
    }
    
    @IBAction func blueSubtractAction(_ sender: UISwipeGestureRecognizer) {
        blueScore -= 1
        blueOutlet.setTitle("\(blueScore)", for: .normal)
    }
    
    
    @IBAction func redErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        redError -= 1
        redErrorOutlet.setTitle("\(redError)", for: .normal)
    }
    
    
    @IBAction func blueErrorSubtractAction(_ sender: UISwipeGestureRecognizer) {
        blueError -= 1
        blueErrorOutlet.setTitle("\(blueError)", for: .normal)
    }
    
    
    @IBAction func longPressRedError(_ sender: UILongPressGestureRecognizer) {
        print("long press happening")
        redError -= 1
        redErrorOutlet.setTitle("\(redError)", for: .normal)
        
    }
}

