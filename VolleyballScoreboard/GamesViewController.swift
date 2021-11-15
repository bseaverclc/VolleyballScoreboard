//
//  GamesViewController.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 10/31/21.
//

import UIKit

class GamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchOutlet: UITextField!
    @IBOutlet weak var tableviewOutlet: UITableView!
    var myTimer: Timer!
    var selectedGame : Game?
    var filteredGames : [Game] = []
    
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
        AppData.allGames = AppData.allGames.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending})
        tableviewOutlet.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredGames.count == 0{
        return AppData.allGames.count
        }
        else{
            return filteredGames.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CrazyCell
        cell.backgroundColor = UIColor.clear
        if indexPath.row % 2 == 0{
            cell.backgroundColor = UIColor.lightGray
        }
        
        if filteredGames.count == 0{
        cell.configure(game: AppData.allGames[indexPath.row])
        }
        else{
        cell.configure(game: filteredGames[indexPath.row])
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.tabBarController!
            vc.selectedIndex = 0
        AppData.selectedGame = AppData.allGames[indexPath.row]
        AppData.canEdit = false
    }
    
    
    @IBAction func searchButtonAction(_ sender: Any) {
        filteredGames = []
        if let team = searchOutlet.text{
        for game in AppData.allGames{
            if game.teams[0].lowercased().starts(with: team.lowercased()) || game.teams[1].lowercased().starts(with: team.lowercased()){
                filteredGames.append(game)
            }
        }
        }
        
        tableviewOutlet.reloadData()
        searchOutlet.resignFirstResponder()
    }
    
    @IBAction func containsSearchAction(_ sender: UIButton) {
        filteredGames = []
        if let team = searchOutlet.text{
        for game in AppData.allGames{
            if game.teams[0].localizedStandardContains(team) || game.teams[1].localizedStandardContains(team){
                filteredGames.append(game)
                
            }
                
        }
        }
        tableviewOutlet.reloadData()
        searchOutlet.resignFirstResponder()
    }
    
    
    
    @IBAction func clearButtonAction(_ sender: Any) {
        filteredGames = []
        searchOutlet.text = ""
        tableviewOutlet.reloadData()
        searchOutlet.resignFirstResponder()
    }
    
  

}
