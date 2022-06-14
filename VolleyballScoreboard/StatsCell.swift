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
    @IBOutlet weak var redAttackErrorsOutlet: UILabel!
    @IBOutlet weak var redAttacksOutlet: UILabel!
    @IBOutlet weak var redHitPctOutlet: UILabel!
    
    @IBOutlet weak var redBlocksOutlet: UILabel!
    @IBOutlet weak var redAcesOutlet: UILabel!
    @IBOutlet weak var redServiceErrorsOutlet: UILabel!
    @IBOutlet weak var redErrorsOutlet: UILabel!
    
    @IBOutlet weak var redPassAvgOutlet: UILabel!
    @IBOutlet weak var redPercentEarnedOutlet: UILabel!

    @IBOutlet weak var bluePointsOutlet: UILabel!
    @IBOutlet weak var blueKillsOutlet: UILabel!
    @IBOutlet weak var blueAttackErrorsOutlet: UILabel!
    @IBOutlet weak var blueAttacksOutlet: UILabel!
    @IBOutlet weak var blueHitPctOutlet: UILabel!
    
    @IBOutlet weak var blueBlocksOutlet: UILabel!
    @IBOutlet weak var blueAcesOutlet: UILabel!
    @IBOutlet weak var blueServiceErrorsOutlet: UILabel!
    @IBOutlet weak var blueErrorsOutlet: UILabel!
    
    @IBOutlet weak var bluePassAvgOutlet: UILabel!
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
        if let rae = blueDict["Opponent Attack Err"]{
            redAttackErrorsOutlet.text = "\(rae)"
        }
        redAttacksOutlet.text = "\(set.redAttack)"
        
        
        redAcesOutlet.text = "\(redDict["Ace"]!)"
        redBlocksOutlet.text = "\(redDict["Block"]!)"
        redServiceErrorsOutlet.text = "\(blueDict["Opponent Serve Err"]!)"
        if let rae = blueDict["Opponent Attack Err"]{
            redErrorsOutlet.text = "\(rae - blueDict["Block"]! + blueDict["Opponent Serve Err"]! + blueDict["Opponent Err"]!)"
        }
        else{
        redErrorsOutlet.text = "\(blueDict["Opponent Err"]! + blueDict["Opponent Serve Err"]!)"
        }
        if Int(set.redStats["redScore"]!) != 0
        {
        redPercentEarnedOutlet.text = "\(Int(round(Double(set.redStats["Ace"]!)/Double(set.redStats["redScore"]!)*100.0 + Double(set.redStats["Kill"]!)/Double(set.redStats["redScore"]!)*100.0 + Double(set.redStats["Block"]!)/Double(set.redStats["redScore"]!)*100.0)))%"
        }
        else{
            redPercentEarnedOutlet.text = "0%"
        }
        
        
        bluePointsOutlet.text = "\(blueDict["blueScore"]!)"
        blueKillsOutlet.text = "\(blueDict["Kill"]!)"
        if let bae = redDict["Opponent Attack Err"]{
            blueAttackErrorsOutlet.text = "\(bae)"
        }
        blueAttacksOutlet.text = "\(set.blueAttack)"
        blueAcesOutlet.text = "\(blueDict["Ace"]!)"
        blueBlocksOutlet.text = "\(blueDict["Block"]!)"
        blueServiceErrorsOutlet.text = "\(redDict["Opponent Serve Err"]!)"
        if let bae = redDict["Opponent Attack Err"]{
            blueErrorsOutlet.text = "\(bae - redDict["Block"]! + redDict["Opponent Serve Err"]! + redDict["Opponent Err"]!)"
        }
        else{
        blueErrorsOutlet.text = "\(redDict["Opponent Err"]! + redDict["Opponent Serve Err"]!)"
        }
        if Int(set.blueStats["blueScore"]!) != 0
        {
        bluePercentEarnedOutlet.text = "\(Int(round(Double(set.blueStats["Ace"]!)/Double(set.blueStats["blueScore"]!)*100.0 + Double(set.blueStats["Kill"]!)/Double(set.blueStats["blueScore"]!)*100.0 + Double(set.blueStats["Block"]!)/Double(set.blueStats["blueScore"]!)*100.0)))%"
        }
        else{
            bluePercentEarnedOutlet.text = "0%"
        }
        
        updatePercents(set: set)
        
    }


    func updatePercents(set : ASet){
        if set.redAttack != 0{
            if let attackErr = set.blueStats["Opponent Attack Err"]{
                //var redPercent = Double(Int((Double(set.redStats["Kill"]! - attackErr)/Double(set.redAttack))*1000))/1000.0
                var redPercent2 = (Double(set.redStats["Kill"]! - attackErr))/Double(set.redAttack)
                var redPercentString = String(format: "%.3f", redPercent2)
                redHitPctOutlet.text = "\(redPercentString)"
            }
            else{
                redHitPctOutlet.text = "NA"
            }
            
            
        }
        else{
            redHitPctOutlet.text = "0.000"
        }
        
        if set.blueAttack != 0{
            if let attackErr = set.redStats["Opponent Attack Err"]{
               // var bluePercent = Double(Int((Double(set.blueStats["Kill"]! - attackErr)/Double(set.blueAttack))*1000))/1000.0
                var bluePercent2 = (Double(set.blueStats["Kill"]! - attackErr))/Double(set.blueAttack)
                var bluePercentString = String(format: "%.3f", bluePercent2)
                blueHitPctOutlet.text = "\(bluePercentString)"
            }
            else{
                blueHitPctOutlet.text = "NA"
            }
            
            
        }
        else{
            blueHitPctOutlet.text = "0.000"
        }
        
//*********** updating pass percentage
        
        var redPasses = set.blueStats["Ace"]! + set.redOne + set.redTwo + set.redThree
        var redPassTotal = set.redOne + 2*set.redTwo + 3*set.redThree
        if redPasses != 0{
            var redAvg = Double(Int((Double(redPassTotal)/Double(redPasses))*100))/100.0
            redPassAvgOutlet.text = "\(redAvg)"
        }
        else{
            redPassAvgOutlet.text = "0.0"
        }

        var bluePasses = set.redStats["Ace"]! + set.blueOne + set.blueTwo + set.blueThree
        var bluePassTotal = set.blueOne + 2*set.blueTwo + 3*set.blueThree
        if bluePasses != 0{
            var blueAvg = Double(Int((Double(bluePassTotal)/Double(bluePasses))*100))/100.0
            bluePassAvgOutlet.text = "\(blueAvg)"
        }
        else{
            bluePassAvgOutlet.text = "0.0"
        }
        
        
        
        

        
        
    }
    

}
