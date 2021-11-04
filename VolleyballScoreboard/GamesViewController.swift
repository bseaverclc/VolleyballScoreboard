//
//  GamesViewController.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 10/31/21.
//

import UIKit

class GamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableviewOutlet: UITableView!
    var myTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableviewOutlet.dataSource = self
        tableviewOutlet.delegate = self
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            self.tableviewOutlet.reloadData()
        }

        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableviewOutlet.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AppData.allGames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CrazyCell
        
        cell.configure(game: AppData.allGames[indexPath.row])
//        var g = AppData.allGames[indexPath.row]
//        cell.textLabel?.text = "\(g.teams[0]): \(g.setWins[0])  vs \(g.teams[1]): \(g.setWins[1])"
        return cell
    }
    

    
    

  

}
