//
//  StatsCell.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 1/10/22.
//

import UIKit
import Foundation

class StatsCell: UITableViewCell {

    @IBOutlet weak var redPointsOutlet: UILabel!
    @IBOutlet weak var redKillsOutlet: UILabel!
    @IBOutlet weak var redBlocksOutlet: UILabel!
    @IBOutlet weak var redAcesOutlet: UILabel!
    @IBOutlet weak var redServiceErrorsOutlet: UILabel!
    @IBOutlet weak var redErrorsOutlet: UILabel!
    @IBOutlet weak var redPercentEarnedOutlet: UILabel!

    @IBOutlet weak var bluePointsOutlet: UILabel!
    @IBOutlet weak var blueKillsOutlet: UILabel!
   
    @IBOutlet weak var blueBlocksOutlet: UILabel!
    @IBOutlet weak var blueAcesOutlet: UILabel!
    @IBOutlet weak var blueServiceErrorsOutlet: UILabel!
    @IBOutlet weak var blueErrorsOutlet: UILabel!
    @IBOutlet weak var bluePercentEarnedOutlet: UILabel!
    
    
    @IBOutlet weak var setNumOutlet: UILabel!
    @IBOutlet weak var redTeamOutlet: UILabel!
    @IBOutlet weak var blueTeamOutlet: UILabel!
    
    
    func configure(set: ASet, setNum: Int, teams: [String])
    {
        setNumOutlet.text = "Set #\(setNum)"
        redTeamOutlet.text = teams[0]
        blueTeamOutlet.text = teams[1]
        
        let redDict = set.redStats
        let blueDict = set.blueStats
        redPointsOutlet.text = "\(redDict["redScore"]!)"
        redKillsOutlet.text = "\(redDict["Kill"]!)"
        redAcesOutlet.text = "\(redDict["Ace"]!)"
        redBlocksOutlet.text = "\(redDict["Block"]!)"
        redServiceErrorsOutlet.text = "\(blueDict["Opponent Serve Err"]!)"
        redErrorsOutlet.text = "\(blueDict["Opponent Err"]!)"
        if Int(set.redStats["redScore"]!) != 0
        {
        redPercentEarnedOutlet.text = "\(Int(round(Double(set.redStats["Ace"]!)/Double(set.redStats["redScore"]!)*100.0 + Double(set.redStats["Kill"]!)/Double(set.redStats["redScore"]!)*100.0 + Double(set.redStats["Block"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
        }
        else{
            redPercentEarnedOutlet.text = "0%"
        }
        
        
        bluePointsOutlet.text = "\(blueDict["blueScore"]!)"
        blueKillsOutlet.text = "\(blueDict["Kill"]!)"
        blueAcesOutlet.text = "\(blueDict["Ace"]!)"
        blueBlocksOutlet.text = "\(blueDict["Block"]!)"
        blueServiceErrorsOutlet.text = "\(redDict["Opponent Serve Err"]!)"
        blueErrorsOutlet.text = "\(redDict["Opponent Err"]!)"
        if Int(set.blueStats["blueScore"]!) != 0
        {
        bluePercentEarnedOutlet.text = "\(Int(round(Double(set.blueStats["Ace"]!)/Double(set.blueStats["blueScore"]!)*100.0 + Double(set.blueStats["Kill"]!)/Double(set.blueStats["blueScore"]!)*100.0 + Double(set.blueStats["Block"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
        }
        else{
            bluePercentEarnedOutlet.text = "0%"
        }
        
    }



}
