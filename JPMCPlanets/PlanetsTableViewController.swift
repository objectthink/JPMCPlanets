//
//  PlanetsTableViewController.swift
//  JPMCPlanets
//
//  Created by stephen eshelman on 9/19/19.
//  Copyright © 2019 stephen eshelman. All rights reserved.
//

import UIKit

class PlanetsTableViewController: UITableViewController {
   
   var _planets:[String] = [String]()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // Uncomment the following line to preserve selection between presentations
      // self.clearsSelectionOnViewWillAppear = false
      
      // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
      // self.navigationItem.rightBarButtonItem = self.editButtonItem
      
      let planetsUrl = URL(string:"https://swapi.co/api/planets/")!
      let task = URLSession.shared.dataTask(with: planetsUrl)
      {(data, response, error) in
         do
         {
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
            {
               // try to read out a string array
               if let results = json["results"] as? [Any]
               {
                  for item in results
                  {
                     //print("ANITEM: \(item)")
                     if let itemDictionary = item as? [String: Any]
                     {
                        if let name = itemDictionary["name"]
                        {
                           print(name)
                           
                           self._planets.append(name as! String)
                        }
                     }
                  }
                  //marshal update onto theui thread
                  DispatchQueue.main.async { // Correct
                     self.tableView.reloadData()
                  }
                  
                  //TODO: write planets to file
               }
            }
         }
         catch let error as NSError
         {
            //TODO: may try to read planets from file if web is not available
            
            print("\(error)")
            
         }
      }
      
      task.resume()
   }
   
   // MARK: - Table view data source
   
   override func numberOfSections(in tableView: UITableView) -> Int {
      // #warning Incomplete implementation, return the number of sections
      return 1
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      // #warning Incomplete implementation, return the number of rows
      return _planets.count
   }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "planetCell", for: indexPath)
    
      // Configure the cell...
      cell.textLabel?.text = _planets[indexPath.row]
      
      return cell
    }
   
   
   /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
   
   /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
    // Delete the row from the data source
    tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
   
   /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    
    }
    */
   
   /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
   
   /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    }
    */
   
}
