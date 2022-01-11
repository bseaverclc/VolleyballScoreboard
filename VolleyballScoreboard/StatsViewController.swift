//
//  StatsViewController.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 1/10/22.
//

import UIKit

class StatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var theGame: Game!
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self

    
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        theGame.sets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! StatsCell
        cell.configure(set: theGame.sets[indexPath.row], setNum: indexPath.row + 1, teams: theGame.teams)
        
        return cell
    }

}
