//
//  HistoryCell.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 1/15/22.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var pointHistStackView: UIStackView!
    @IBOutlet weak var redHowOutlet: UILabel!
    @IBOutlet weak var redRotationOutlet: UILabel!
    @IBOutlet weak var scoreOutlet: UILabel!
    @IBOutlet weak var blueRotationOutlet: UILabel!
    @IBOutlet weak var blueHowOutlet: UILabel!
    
    
    @IBOutlet weak var red2HowOutlet: UILabel!
    @IBOutlet weak var red2RotationOutlet: UILabel!
    @IBOutlet weak var red2Score: UILabel!
    
    
    @IBOutlet weak var blue2HowOutlet: UILabel!
    @IBOutlet weak var blue2RotationOutlet: UILabel!
    
    var switchPoint = false
    
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
        redRotationOutlet.text = "\(point.redRotation + 1)"
        blueRotationOutlet.text = "\(point.blueRotation + 1)"
        redRotationOutlet.backgroundColor = UIColor.white
        blueRotationOutlet.backgroundColor = UIColor.white
        if point.serve == "red"{
            redRotationOutlet.text = "\(point.redRotation + 1)*"
            redRotationOutlet.backgroundColor = UIColor.yellow
            blueRotationOutlet.text = "\(point.blueRotation + 1)"
        }
        else{
            redRotationOutlet.text = "\(point.redRotation + 1)"
            blueRotationOutlet.text = "\(point.blueRotation + 1)*"
            blueRotationOutlet.backgroundColor = UIColor.yellow
        }
        
        scoreOutlet.text = point.score
        
    }
    
    func pointArrangement(switched: Bool){
        switchPoint = switched
//        pointHistStackView.removeArrangedSubview(red2RotationOutlet)
//        pointHistStackView.removeArrangedSubview(red2HowOutlet)
//        pointHistStackView.removeArrangedSubview(red2Score)
//        pointHistStackView.removeArrangedSubview(blue2HowOutlet)
//        pointHistStackView.removeArrangedSubview(blue2RotationOutlet)
////
//        if !switched{
//        pointHistStackView.addArrangedSubview(red2RotationOutlet)
//        pointHistStackView.addArrangedSubview(red2HowOutlet)
//        pointHistStackView.addArrangedSubview(red2Score)
//        pointHistStackView.addArrangedSubview(blue2HowOutlet)
//        pointHistStackView.addArrangedSubview(blue2RotationOutlet)
//        }
//        else{
//            pointHistStackView.addArrangedSubview(blue2RotationOutlet)
//            pointHistStackView.addArrangedSubview(blue2HowOutlet)
//            pointHistStackView.addArrangedSubview(red2Score)
//            pointHistStackView.addArrangedSubview(red2HowOutlet)
//            pointHistStackView.addArrangedSubview(red2RotationOutlet)
//
//        }
        //pointHistStackView.setNeedsLayout()
        //pointHistStackView.layoutIfNeeded()
    }
    
    func configure2(point: Point){
       
        if !switchPoint{
        if(point.who == "red")
        {
            if point.why == "Opponent Serve Err"{
                red2HowOutlet.text = "Opp Sv Err"
            }
            else if point.why == "Opponent Err"{
                red2HowOutlet.text = "Opp Err"
            }
            else{
            red2HowOutlet.text = point.why
            }
            
            red2HowOutlet.backgroundColor = UIColor.green
            
            if point.why.contains("Err"){
                blue2HowOutlet.backgroundColor = UIColor.red
            }
            else{
                blue2HowOutlet.backgroundColor = UIColor.white
            }
            blue2HowOutlet.text  = ""
        }
        else{
            
            if point.why == "Opponent Serve Err"{
                blue2HowOutlet.text = "Opp Sv Err"
            }
            else if point.why == "Opponent Err"{
                blue2HowOutlet.text = "Opp Err"
            }
            else{
            blue2HowOutlet.text  = point.why
            }
            
            blue2HowOutlet.backgroundColor = UIColor.green
            
            if point.why.contains("Err"){
                red2HowOutlet.backgroundColor = UIColor.red
            }
            else {
                red2HowOutlet.backgroundColor = UIColor.white
                
            }
            red2HowOutlet.text = ""

        }
        red2RotationOutlet.text = "\(point.redRotation + 1)"
        blue2RotationOutlet.text = "\(point.blueRotation + 1)"
        red2RotationOutlet.backgroundColor = UIColor.white
        blue2RotationOutlet.backgroundColor = UIColor.white
        if point.serve == "red"{
            red2RotationOutlet.text = "\(point.redRotation + 1)*"
            red2RotationOutlet.backgroundColor = UIColor.yellow
            blue2RotationOutlet.text = "\(point.blueRotation + 1)"
        }
        else{
            red2RotationOutlet.text = "\(point.redRotation + 1)"
            blue2RotationOutlet.text = "\(point.blueRotation + 1)*"
            blue2RotationOutlet.backgroundColor = UIColor.yellow
        }
            
            red2Score.text = point.score
        }
            else{
                if(point.who == "red")
                {
                    if point.why == "Opponent Serve Err"{
                        blue2HowOutlet.text = "Opp Sv Err"
                    }
                    else if point.why == "Opponent Err"{
                        blue2HowOutlet.text = "Opp Err"
                    }
                    else{
                    blue2HowOutlet.text = point.why
                    }
                    
                    blue2HowOutlet.backgroundColor = UIColor.green
                    
                    if point.why.contains("Err"){
                        red2HowOutlet.backgroundColor = UIColor.red
                    }
                    else{
                        red2HowOutlet.backgroundColor = UIColor.white
                    }
                    red2HowOutlet.text  = ""
                }
                else{
                    
                    if point.why == "Opponent Serve Err"{
                        red2HowOutlet.text = "Opp Sv Err"
                    }
                    else if point.why == "Opponent Err"{
                        red2HowOutlet.text = "Opp Err"
                    }
                    else{
                        red2HowOutlet.text  = point.why
                    }
                    
                    red2HowOutlet.backgroundColor = UIColor.green
                    
                    if point.why.contains("Err"){
                        blue2HowOutlet.backgroundColor = UIColor.red
                    }
                    else {
                        blue2HowOutlet.backgroundColor = UIColor.white
                        
                    }
                    blue2HowOutlet.text = ""

                }
                blue2RotationOutlet.text = "\(point.redRotation + 1)"
                red2RotationOutlet.text = "\(point.blueRotation + 1)"
                blue2RotationOutlet.backgroundColor = UIColor.white
                red2RotationOutlet.backgroundColor = UIColor.white
                if point.serve == "red"{
                    blue2RotationOutlet.text = "\(point.redRotation + 1)*"
                    blue2RotationOutlet.backgroundColor = UIColor.yellow
                    red2RotationOutlet.text = "\(point.blueRotation + 1)"
                }
                else{
                    blue2RotationOutlet.text = "\(point.redRotation + 1)"
                    red2RotationOutlet.text = "\(point.blueRotation + 1)*"
                    red2RotationOutlet.backgroundColor = UIColor.yellow
                }

            let splits = point.score.split(separator: "-")
            if splits.count > 1{
                var newScore = "\(splits[1])-\(splits[0])"
                red2Score.text = newScore
            }
            else{
                red2Score.text = "??-??"
            }
                
            }
            
            
        }
        
        
        
        
    
    
}
