//
//  CrazyCell.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 11/1/21.
//

import Foundation
import UIKit

class CrazyCell: UITableViewCell
{
    
    @IBOutlet weak var redTeamOutlet: UILabel!
    @IBOutlet weak var blueTeamOutlet: UILabel!
    
    
    @IBOutlet weak var redS1Outlet: UILabel!
    @IBOutlet weak var redS2Outlet: UILabel!
    @IBOutlet weak var redS3Outlet: UILabel!
    @IBOutlet weak var redS4Outlet: UILabel!
    @IBOutlet weak var redS5Outlet: UILabel!
    
    
    @IBOutlet weak var blueS1Outlet: UILabel!
    @IBOutlet weak var blueS2Outlet: UILabel!
    @IBOutlet weak var blueS3Outlet: UILabel!
    @IBOutlet weak var blueS4Outlet: UILabel!
    @IBOutlet weak var blueS5Outlet: UILabel!
    
    
    @IBOutlet weak var dateOutlet: UILabel!
    @IBOutlet weak var timeOutlet: UILabel!
    @IBOutlet weak var LocationOutlet: UILabel!
    
    func configure(game: Game)
    {
        
        
        redTeamOutlet.text = game.teams[0]
        blueTeamOutlet.text = game.teams[1]
        
        redS1Outlet.text = "\(game.sets[0].redStats["redScore"]!)"
        redS2Outlet.text = "\(game.sets[1].redStats["redScore"]!)"
        redS3Outlet.text = "\(game.sets[2].redStats["redScore"]!)"
        if game.sets.count > 3{
        redS4Outlet.text = "\(game.sets[3].redStats["redScore"]!)"
        redS5Outlet.text = "\(game.sets[4].redStats["redScore"]!)"
        }
        else{
            redS4Outlet.text = "0"
            redS5Outlet.text = "0"
        }
        
        blueS1Outlet.text = "\(game.sets[0].blueStats["blueScore"]!)"
        blueS2Outlet.text = "\(game.sets[1].blueStats["blueScore"]!)"
        blueS3Outlet.text = "\(game.sets[2].blueStats["blueScore"]!)"
        if game.sets.count > 3{
        blueS4Outlet.text = "\(game.sets[3].blueStats["blueScore"]!)"
        blueS5Outlet.text = "\(game.sets[4].blueStats["blueScore"]!)"
        }
        else{
            blueS4Outlet.text = "0"
            blueS5Outlet.text = "0"
        }
        
        
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "MM/D/YY"
        dateFormatter.dateStyle = .short
        let convertedDate = dateFormatter.string(from: game.date)
        // switched time and date outlet to show date in middle temporarily until time works
        dateOutlet.text = "\(convertedDate)"
        dateFormatter.timeZone = .autoupdatingCurrent
        let TimeFormatter = DateFormatter()
        TimeFormatter.timeZone = .autoupdatingCurrent
       TimeFormatter.timeStyle = .short
        TimeFormatter.dateStyle = .none
        
        
        let convertedTime = TimeFormatter.string(from: game.date)
        
        timeOutlet.text = convertedTime
       // highlightWinner(game: game)
        
    }
    
    func highlightWinner(game: Game){
        redTeamOutlet.backgroundColor = UIColor.clear
        blueTeamOutlet.backgroundColor = UIColor.clear
        var redWins = 0
        var blueWins = 0
        
        for i in 0...1{
        var redScore = Int(exactly: game.sets[i].redStats["redScore"]!)!
        var blueScore = Int(exactly: game.sets[i].blueStats["blueScore"]!)!
//        print("redScore: \(redScore)")
//            print("blueScore: \(blueScore)")
        if redScore - blueScore >= 2 && redScore >= 25{
            redWins += 1
        }
        if blueScore - redScore >= 2 && blueScore >= 25{
            blueWins += 1
        }
        }
        
        var redScore3 = Int(exactly: game.sets[2].redStats["redScore"]!)!
        var blueScore3 = Int(exactly: game.sets[2].blueStats["blueScore"]!)!
        if redScore3 - blueScore3 >= 2 && redScore3 >= 15{
            redWins += 1
        }
        if blueScore3 - redScore3 >= 2 && blueScore3 >= 15{
            blueWins += 1
        }
        
        if redWins >= 2{
            redTeamOutlet.backgroundColor = UIColor.green
        }
        if blueWins >= 2{
            blueTeamOutlet.backgroundColor = UIColor.green
        }
    }
}
