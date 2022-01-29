//
//  GamesViewController.swift
//  VolleyballScoreboard
//
//  Created by Brian Seaver on 10/31/21.
//

import UIKit

class GamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var searchOutlet: UITextField!
    @IBOutlet weak var tableviewOutlet: UITableView!
    var myTimer: Timer!
    var selectedGame : Game?
   static var filteredGames : [Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableviewOutlet.dataSource = self
        tableviewOutlet.delegate = self
        searchOutlet.delegate = self
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            self.tableviewOutlet.reloadData()
        }

        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppData.allGames = AppData.allGames.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending})
        GamesViewController.filteredGames = GamesViewController.filteredGames.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending})
        tableviewOutlet.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        GamesViewController.filteredGames = []
        if let team = searchOutlet.text{
        for game in AppData.allGames{
            if game.teams[0].localizedStandardContains(team) || game.teams[1].localizedStandardContains(team){
                GamesViewController.filteredGames.append(game)
                
            }
                
        }
        }
        tableviewOutlet.reloadData()
        searchOutlet.resignFirstResponder()
        return true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if GamesViewController.filteredGames.count == 0{
        return AppData.allGames.count
        }
        else{
            return GamesViewController.filteredGames.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CrazyCell
        cell.backgroundColor = UIColor.clear
        if indexPath.row % 2 == 0{
            cell.backgroundColor = UIColor.lightGray
        }
        
        if GamesViewController.filteredGames.count == 0{
        cell.configure(game: AppData.allGames[indexPath.row])
        }
        else{
        cell.configure(game: GamesViewController.filteredGames[indexPath.row])
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.tabBarController!
            vc.selectedIndex = 1
        if GamesViewController.filteredGames.count == 0{
        AppData.selectedGame = AppData.allGames[indexPath.row]
        }
        else{
            AppData.selectedGame =  GamesViewController.filteredGames[indexPath.row]
        }
        AppData.canEdit = false
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if AppData.canDelete && GamesViewController.filteredGames.count == 0{
            return true
        }
        else{return false}
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            let alert = UIAlertController(title: "Alert!", message: "Are you sure you want to delete this game?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { a in
                
                AppData.allGames[indexPath.row].deleteFromFirebase()
                AppData.allGames.remove(at: indexPath.row)

                
                tableView.reloadData()
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        GamesViewController.filteredGames = []
        if let team = searchOutlet.text{
        for game in AppData.allGames{
            if game.teams[0].lowercased().starts(with: team.lowercased()) || game.teams[1].lowercased().starts(with: team.lowercased()){
                GamesViewController.filteredGames.append(game)
            }
        }
        }
        
        tableviewOutlet.reloadData()
        searchOutlet.resignFirstResponder()
    }
    
    @IBAction func containsSearchAction(_ sender: UIButton) {
        GamesViewController.filteredGames = []
        if let team = searchOutlet.text{
        for game in AppData.allGames{
            if game.teams[0].localizedStandardContains(team) || game.teams[1].localizedStandardContains(team){
                GamesViewController.filteredGames.append(game)
                
            }
                
        }
        }
        tableviewOutlet.reloadData()
        searchOutlet.resignFirstResponder()
    }
    
    
    
    @IBAction func clearButtonAction(_ sender: Any) {
        GamesViewController.filteredGames = []
        searchOutlet.text = ""
        AppData.allGames = AppData.allGames.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending})
        tableviewOutlet.reloadData()
        searchOutlet.resignFirstResponder()
    }
    
  
    @IBAction func longPressCodeAction(_ sender: UILongPressGestureRecognizer) {
        
        let alert = UIAlertController(title: "Delete Code?", message: "Enter Delete Code", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Code"
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { alerty in
            let codeText = alert.textFields![0].text
            if codeText == "314159"{
                AppData.canDelete = true
            }
        }

        alert.addAction(submitAction)
        present(alert, animated: true, completion: nil)
        
    }
    
}
