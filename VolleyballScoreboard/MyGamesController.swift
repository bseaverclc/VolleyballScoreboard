//
//  MyGamesController.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 11/4/21.
//

import UIKit

class MyGamesController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableviewOutlet: UITableView!
    var myTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableviewOutlet.dataSource = self
        tableviewOutlet.delegate = self
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        AppData.myGames = AppData.myGames.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending})
        tableviewOutlet.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AppData.myGames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CrazyCell
        
        cell.configure(game: AppData.myGames[indexPath.row])
//        var g = AppData.allGames[indexPath.row]
//        cell.textLabel?.text = "\(g.teams[0]): \(g.setWins[0])  vs \(g.teams[1]): \(g.setWins[1])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.tabBarController!
            vc.selectedIndex = 0
        AppData.selectedGame = AppData.myGames[indexPath.row]
        AppData.canEdit = true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            let alert = UIAlertController(title: "Alert!", message: "Are you sure you want to delete this game?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { a in
                AppData.myGames.remove(at: indexPath.row)
//                AppData.allGames[indexPath.row].delete!
//                AppData.allGames.remove(at: indexPath.row)
                
                tableView.reloadData()
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(AppData.myGames) {
                                   UserDefaults.standard.set(encoded, forKey: "myGames")
                               }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

  

}
