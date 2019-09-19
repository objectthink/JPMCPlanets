//
//  PlanetInfoTableViewController.swift
//  JPMCPlanets
//
//  Created by stephen eshelman on 9/19/19.
//  Copyright © 2019 stephen eshelman. All rights reserved.
//

import UIKit

//use a protocol so that we can create new controllers
//that can be used to visualize planet info
protocol usesPlanetInfo {
   var planetInfo: [String: Any] { set get }
}

//view controller used to display planet info
class PlanetInfoTableViewController: UITableViewController, usesPlanetInfo {
   
   var _planetInfo: [String:Any] = [:]
   var planetInfo: [String : Any]
   {
      get
      {
         return _planetInfo
      }
      set
      {
         _planetInfo = newValue
         
         self.tableView.reloadData()
      }
   }

   //viewDidLoad
   override func viewDidLoad() {
      super.viewDidLoad()
      
      //set title
      navigationItem.title = planetInfo["name"] as? String
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "planetInfoCell", for: indexPath)
      
      switch indexPath.row
      {
      case 0:
         cell.detailTextLabel?.text = planetInfo["gravity"] as? String
         cell.textLabel?.text = "Gravity"
      case 1:
         cell.detailTextLabel?.text = planetInfo["terrain"] as? String
         cell.textLabel?.text = "Terrain"
      case 2:
         cell.detailTextLabel?.text = planetInfo["climate"] as? String
         cell.textLabel?.text = "Climate"
      case 3:
         cell.detailTextLabel?.text = planetInfo["diameter"] as? String
         cell.textLabel?.text = "Diameter"
      case 4:
         cell.detailTextLabel?.text = planetInfo["population"] as? String
         cell.textLabel?.text = "Population"
      case 5:
         cell.detailTextLabel?.text = planetInfo["surface_water"] as? String
         cell.textLabel?.text = "Surface Water"
      case 6:
         cell.detailTextLabel?.text = planetInfo["rotation_period"] as? String
         cell.textLabel?.text = "Rotation Period"
      default:
         cell.detailTextLabel?.text = "Unknown"
         cell.textLabel?.text = "Unkown"
      }

      return cell
   }
}
