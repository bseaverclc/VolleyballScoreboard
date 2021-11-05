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
    
    
    @IBOutlet weak var blueS1Outlet: UILabel!
    @IBOutlet weak var blueS2Outlet: UILabel!
    @IBOutlet weak var blueS3Outlet: UILabel!
    
    
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
        
        blueS1Outlet.text = "\(game.sets[0].blueStats["blueScore"]!)"
        blueS2Outlet.text = "\(game.sets[1].blueStats["blueScore"]!)"
        blueS3Outlet.text = "\(game.sets[2].blueStats["blueScore"]!)"
        
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "MM/D/YY"
        dateFormatter.dateStyle = .short
        let convertedDate = dateFormatter.string(from: game.date)
        dateOutlet.text = "\(convertedDate)"
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        
        let convertedTime = dateFormatter.string(from: game.date)
        timeOutlet.text = "\(convertedTime)"
        
    }
}
