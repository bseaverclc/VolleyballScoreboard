//
//  MyGamesController.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 11/4/21.
//

import UIKit

class MyGamesController:  UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var searchOutlet: UITextField!
    @IBOutlet weak var tableviewOutlet: UITableView!
    var myTimer: Timer!
    var filteredGames : [Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableviewOutlet.dataSource = self
        tableviewOutlet.delegate = self
        searchOutlet.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        AppData.myGames = AppData.myGames.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending})
        tableviewOutlet.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        filteredGames = []
        if let team = searchOutlet.text{
        for game in AppData.myGames{
            if game.teams[0].localizedStandardContains(team) || game.teams[1].localizedStandardContains(team){
                filteredGames.append(game)
            }
        }
        }
        tableviewOutlet.reloadData()
        searchOutlet.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredGames.count == 0{
        return AppData.myGames.count
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
            cell.configure(game: AppData.myGames[indexPath.row])
        }
        else{
            cell.configure(game: filteredGames[indexPath.row])
        }
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.tabBarController!
            vc.selectedIndex = 1
        AppData.selectedGame = AppData.myGames[indexPath.row]
        
        AppData.canEdit = true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            let alert = UIAlertController(title: "Alert!", message: "Are you sure you want to delete this game?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { a in
                //reset scoreboard screen
                if let sg = AppData.selectedGame{
                    if sg.uid == AppData.myGames[indexPath.row].uid{
                        AppData.selectedGame = nil
                    }
                }
                AppData.myGames[indexPath.row].deleteFromFirebase()
                AppData.myGames.remove(at: indexPath.row)
                

                
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

    @IBAction func searchButtonAction(_ sender: Any) {
        filteredGames = []
        if let team = searchOutlet.text{
        for game in AppData.myGames{
            if game.teams[0].lowercased().starts(with: team.lowercased()) || game.teams[1].lowercased().starts(with: team.lowercased()){
                filteredGames.append(game)
            }
        }
        }
        tableviewOutlet.reloadData()
        searchOutlet.resignFirstResponder()
    }
    
    @IBAction func containsAction(_ sender: UIButton) {
        filteredGames = []
        if let team = searchOutlet.text{
        for game in AppData.myGames{
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
