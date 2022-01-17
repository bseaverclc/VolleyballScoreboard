//
//  HistoryCell.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 1/15/22.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var redHowOutlet: UILabel!
    @IBOutlet weak var redRotationOutlet: UILabel!
    @IBOutlet weak var scoreOutlet: UILabel!
    @IBOutlet weak var blueRotationOutlet: UILabel!
    @IBOutlet weak var blueHowOutlet: UILabel!
    
    func configure(point: Point)
    {
        if(point.who == "red")
        {
            if point.why == "Opponent Serve Err"{
                redHowOutlet.text = "Opp Sv Err"
            }
            else if point.why == "Opponent Err"{
                redHowOutlet.text = "Opp Err"
            }
            else{
            redHowOutlet.text = point.why
            }
            
            redHowOutlet.backgroundColor = UIColor.green
            
            if point.why.contains("Err"){
                blueHowOutlet.backgroundColor = UIColor.red
            }
            else{
                blueHowOutlet.backgroundColor = UIColor.white
            }
            blueHowOutlet.text  = ""
        }
        else{
            
            if point.why == "Opponent Serve Err"{
                blueHowOutlet.text = "Opp Sv Err"
            }
            else if point.why == "Opponent Err"{
                blueHowOutlet.text = "Opp Err"
            }
            else{
            blueHowOutlet.text  = point.why
            }
            
            blueHowOutlet.backgroundColor = UIColor.green
            
            if point.why.contains("Err"){
                redHowOutlet.backgroundColor = UIColor.red
            }
            else {
                redHowOutlet.backgroundColor = UIColor.white
                
            }
            redHowOutlet.text = ""

        }
        redRotationOutlet.text = "\(point.redRotation)"
        blueRotationOutlet.text = "\(point.blueRotation)"
        if point.serve == "red"{
            redRotationOutlet.text = "\(point.redRotation)*"
            blueRotationOutlet.text = "\(point.blueRotation)"
        }
        else{
            redRotationOutlet.text = "\(point.redRotation)"
            blueRotationOutlet.text = "\(point.blueRotation)*"
        }
        
        scoreOutlet.text = point.score
        
    }
    
}
