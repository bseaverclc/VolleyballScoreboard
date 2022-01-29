//
//  HistoryViewController.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 1/15/22.
//

import UIKit
import Foundation

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var set: ASet!
    var setNum: Int!
    var game: Game!
    
    @IBOutlet weak var setOutlet: UILabel!
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    @IBOutlet var redRotationPlusMinusOutlets: [UILabel]!
    
    @IBOutlet var blueRotationPlusMinusOutlets: [UILabel]!
    
    @IBOutlet weak var redTeamOulet: UILabel!
    @IBOutlet weak var blueTeamOutlet: UILabel!
    @IBOutlet weak var redTeamRotationOutlet: UILabel!
    
    @IBOutlet weak var blueTeamRotationOutlet: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        scrollToBottom()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        setOutlet.text = "Set \(setNum!)"
        redTeamOulet.text = game.teams[0]
        blueTeamOutlet.text = game.teams[1]
        redTeamRotationOutlet.text = game.teams[0]
        blueTeamRotationOutlet.text = game.teams[1]
        
        var i = 0
        for label in redRotationPlusMinusOutlets{
            label.text = "\(set.redRotationPlusMinus[i])"
            if set.redRotationPlusMinus[i] > 0{
                label.backgroundColor = UIColor.green
            }
            else if set.redRotationPlusMinus[i] < 0{
                label.backgroundColor = UIColor.red
            }
            i+=1
        }
        
        i = 0
        for label in blueRotationPlusMinusOutlets{
            label.text = "\(set.blueRotationPlusMinus[i])"
            if set.blueRotationPlusMinus[i] > 0{
                label.backgroundColor = UIColor.green
            }
            else if set.blueRotationPlusMinus[i] < 0{
                label.backgroundColor = UIColor.red
            }
            i+=1
        }
        
        

    }
    
    func scrollToBottom(){
        if(set.pointHistory.count != 0)
            
        {
        let indexPath = IndexPath(item: set.pointHistory.count - 1, section: 0)
        tableViewOutlet.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        set.pointHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! HistoryCell
        cell.configure(point: set.pointHistory[indexPath.row])
        
        
        return cell
    }
    


}
