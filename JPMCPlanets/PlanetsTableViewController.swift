//
//  PlanetsTableViewController.swift
//  JPMCPlanets
//
//  Created by stephen eshelman on 9/19/19.
//  Copyright © 2019 stephen eshelman. All rights reserved.
//

import UIKit

class PlanetsTableViewController: UITableViewController {
   
   //store planet names and a dictionary of planet info
   var _planets:[String] = [String]()
   var _planetInfo:[String:[String:Any]] = [:]
   var _selected:String = ""
   var _page = 1
   
   //store last saved planet name and dictionary of planet info
   var _lastPlanets:[String] = [String]()
   var _lastPlanetInfo:[String:[String:Any]] = [:]
   
   //which section was the selectin from
   var _selectedSection:Int = 0
   
   //next/previous buttons
   @IBOutlet weak var _nextButton: UIBarButtonItem!
   @IBOutlet weak var _previousButton: UIBarButtonItem!
   
   
   @IBAction func nextPage(_ sender: UIBarButtonItem) {
      _page = _page + 1
      
      //clear current planets
      _planets.removeAll()
      _planetInfo.removeAll()
      
      //clear last planets
      _lastPlanets.removeAll()
      _lastPlanetInfo.removeAll()
      
      fetchPage()
   }
   
   @IBAction func previousPage(_ sender: UIBarButtonItem) {
      _page = _page - 1
      
      if _page < 0
      {
         _page = 0
      }
      
      //clear current planets
      _planets.removeAll()
      _planetInfo.removeAll()
      
      //clear last planets
      _lastPlanets.removeAll()
      _lastPlanetInfo.removeAll()
      
      fetchPage()
   }
   
   //get the documents dirctory
   //used to construct name of file to save planets json to
   func getDocumentsDirectory() -> URL {
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      return paths[0]
   }
   
   //save the json returned from website
   func writePlanetsToFile(data:Data)
   {
      do
      {
         let filename = self.getDocumentsDirectory().appendingPathComponent("planets.json")
         
         print(filename)
         
         try data.write(to: filename)
      }
      catch
      {
         //TODO: alert on failure
         print("write failed")
      }

   }
   
   //read the json saved in previous session
   //and create last saved planets
   //will fail the first time as file will not exist
   func readPlanetsFromFile()
   {
      do
      {
         let filename = self.getDocumentsDirectory().appendingPathComponent("planets.json")

         let ndata:Data = try Data(contentsOf: filename)
         let njson = try JSONSerialization.jsonObject(with: ndata, options: []) as? [String: Any]
         let nresults = njson!["results"] as? [Any]
         
         for item in nresults!
         {
            //print("ANITEM: \(item)")
            if let itemDictionary = item as? [String: Any]
            {
               if let name = itemDictionary["name"]
               {
                  print(name)
                  
                  self._lastPlanets.append(name as! String)
                  self._lastPlanetInfo[name as! String] = itemDictionary
               }
            }
         }
      }
      catch
      {
         //TODO: alert on failure
         print("read failed")
      }
   }
   
   func alert(message:String)
   {
      //marshal update onto the ui thread
      DispatchQueue.main.async {
         print("\(message)")
         
         let alertController =
            UIAlertController(title: "Planets Fetch Error", message:"\(message)", preferredStyle: .alert)
         
         alertController.addAction(UIAlertAction(title: "OK", style: .default))

         self.present(alertController, animated: true, completion: nil)
      }
   }
   
   func fetchPage()
   {
      _nextButton.isEnabled = false;
      _previousButton.isEnabled = false;
      
      //DEMONSTRATE HOW TO QUERY FOR PAGE - pass page argument
      //let planetsUrl = URL(string:"https://swapi.co/api/planets/?page=3")!

      //TODO: move this request, read, and write logic to a function to allow for "next page" button
      let planetsUrl = URL(string:"https://swapi.co/api/planets/?page=\(_page)")!
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
                           
                           self._planetInfo[name as! String] = itemDictionary
                        }
                     }
                  }
                  
                  //update if there were results
                  if results.count > 0
                  {
                     //marshal update onto the ui thread
                     DispatchQueue.main.async { // Correct
                        //TODO: write planets to file
                        self.readPlanetsFromFile()
                        self.writePlanetsToFile(data: data!)

                        self.tableView.reloadData()
                        
                        //TODO:move button disposition updates to a function
                        //enable/disable page navigation while planets are being fetched
                        //so as to not attempt table view updates until after planets are fetched
                        self._nextButton.isEnabled = true
                        self._previousButton.isEnabled = true
                        
                        //DEBUG
                        //print(self._planetInfo["Bespin"]!["gravity"]!)
                        //print(self._planetInfo["Bespin"]!["terrain"]!)
                     }
                  }
                  else
                  {
                     //enable/disable page navigation while planets are being fetched
                     self._nextButton.isEnabled = true
                     self._previousButton.isEnabled = true
                  }
               }
               else
               {
                  let detail = json["detail"] as? String
                  
                  self.alert(message:detail!)
                  
                  //enable/disable page navigation while planets are being fetched
                  self._nextButton.isEnabled = true
                  self._previousButton.isEnabled = true
               }
            }

         }
         catch let error as NSError
         {
            //TODO: may try to read planets from file if web is not available
            self.alert(message:error.localizedDescription)
            
            //enable/disable page navigation while planets are being fetched
            self._nextButton.isEnabled = true
            self._previousButton.isEnabled = true
         }
      }
      
      task.resume()
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      fetchPage()
   }
   
   // MARK: - Table view data source
   
   override func numberOfSections(in tableView: UITableView) -> Int {
      // #warning Incomplete implementation, return the number of sections
      return 2
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      switch section
      {
      case 0:
         return _planets.count
      case 1:
         return _lastPlanets.count
      default:
         return 0
      }
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "planetCell", for: indexPath)
      
      // Configure the cell...
      switch indexPath.section
      {
      case 0:
         cell.textLabel?.text = _planets[indexPath.row]
      case 1:
         cell.textLabel?.text = _lastPlanets[indexPath.row]
      default:
         cell.textLabel?.text = ""
      }
      
      return cell
   }
   
   override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      let sectionName: String
      
      switch section {
      case 0:
         sectionName = "Current"
      case 1:
         sectionName = "Last"
      default:
         sectionName = ""
      }
      
      return sectionName
   }
   
   override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
      switch indexPath.section
      {
      case 0:
         _selected = _planets[indexPath.row]
         _selectedSection = 0
      case 1:
         _selected = _lastPlanets[indexPath.row]
         _selectedSection = 1
      default:
         _selected = ""
      }
      
      return indexPath
   }
   
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destination.
      // Pass the selected object to the new view controller.
      
      if segue.identifier == "planetInfoSegue"
      {
         print("got planet info segue")
         if var destination = segue.destination as? usesPlanetInfo
         {
            switch _selectedSection
            {
            case 0:
               destination.planetInfo = _planetInfo[_selected]!
            case 1:
               destination.planetInfo = _lastPlanetInfo[_selected]!
            default:
               destination.planetInfo = _planetInfo[_selected]!

            }
         }
      }
   }
   
   /*
    PLANETS EXAMPLE JSON https://swapi.co/api/planets/
    HTTP 200 OK
    Allow: GET, HEAD, OPTIONS
    Content-Type: application/json
    Vary: Accept
    
    {
    "count": 61,
    "next": "https://swapi.co/api/planets/?page=2",
    "previous": null,
    "results": [
    {
    "name": "Alderaan",
    "rotation_period": "24",
    "orbital_period": "364",
    "diameter": "12500",
    "climate": "temperate",
    "gravity": "1 standard",
    "terrain": "grasslands, mountains",
    "surface_water": "40",
    "population": "2000000000",
    "residents": [
    "https://swapi.co/api/people/5/",
    "https://swapi.co/api/people/68/",
    "https://swapi.co/api/people/81/"
    ],
    "films": [
    "https://swapi.co/api/films/6/",
    "https://swapi.co/api/films/1/"
    ],
    "created": "2014-12-10T11:35:48.479000Z",
    "edited": "2014-12-20T20:58:18.420000Z",
    "url": "https://swapi.co/api/planets/2/"
    },
    {
    "name": "Yavin IV",
    "rotation_period": "24",
    "orbital_period": "4818",
    "diameter": "10200",
    "climate": "temperate, tropical",
    "gravity": "1 standard",
    "terrain": "jungle, rainforests",
    "surface_water": "8",
    "population": "1000",
    "residents": [],
    "films": [
    "https://swapi.co/api/films/1/"
    ],
    "created": "2014-12-10T11:37:19.144000Z",
    "edited": "2014-12-20T20:58:18.421000Z",
    "url": "https://swapi.co/api/planets/3/"
    },
    {
    "name": "Hoth",
    "rotation_period": "23",
    "orbital_period": "549",
    "diameter": "7200",
    "climate": "frozen",
    "gravity": "1.1 standard",
    "terrain": "tundra, ice caves, mountain ranges",
    "surface_water": "100",
    "population": "unknown",
    "residents": [],
    "films": [
    "https://swapi.co/api/films/2/"
    ],
    "created": "2014-12-10T11:39:13.934000Z",
    "edited": "2014-12-20T20:58:18.423000Z",
    "url": "https://swapi.co/api/planets/4/"
    },
    {
    "name": "Dagobah",
    "rotation_period": "23",
    "orbital_period": "341",
    "diameter": "8900",
    "climate": "murky",
    "gravity": "N/A",
    "terrain": "swamp, jungles",
    "surface_water": "8",
    "population": "unknown",
    "residents": [],
    "films": [
    "https://swapi.co/api/films/2/",
    "https://swapi.co/api/films/6/",
    "https://swapi.co/api/films/3/"
    ],
    "created": "2014-12-10T11:42:22.590000Z",
    "edited": "2014-12-20T20:58:18.425000Z",
    "url": "https://swapi.co/api/planets/5/"
    },
    {
    "name": "Bespin",
    "rotation_period": "12",
    "orbital_period": "5110",
    "diameter": "118000",
    "climate": "temperate",
    "gravity": "1.5 (surface), 1 standard (Cloud City)",
    "terrain": "gas giant",
    "surface_water": "0",
    "population": "6000000",
    "residents": [
    "https://swapi.co/api/people/26/"
    ],
    "films": [
    "https://swapi.co/api/films/2/"
    ],
    "created": "2014-12-10T11:43:55.240000Z",
    "edited": "2014-12-20T20:58:18.427000Z",
    "url": "https://swapi.co/api/planets/6/"
    },
    {
    "name": "Endor",
    "rotation_period": "18",
    "orbital_period": "402",
    "diameter": "4900",
    "climate": "temperate",
    "gravity": "0.85 standard",
    "terrain": "forests, mountains, lakes",
    "surface_water": "8",
    "population": "30000000",
    "residents": [
    "https://swapi.co/api/people/30/"
    ],
    "films": [
    "https://swapi.co/api/films/3/"
    ],
    "created": "2014-12-10T11:50:29.349000Z",
    "edited": "2014-12-20T20:58:18.429000Z",
    "url": "https://swapi.co/api/planets/7/"
    },
    {
    "name": "Naboo",
    "rotation_period": "26",
    "orbital_period": "312",
    "diameter": "12120",
    "climate": "temperate",
    "gravity": "1 standard",
    "terrain": "grassy hills, swamps, forests, mountains",
    "surface_water": "12",
    "population": "4500000000",
    "residents": [
    "https://swapi.co/api/people/3/",
    "https://swapi.co/api/people/21/",
    "https://swapi.co/api/people/36/",
    "https://swapi.co/api/people/37/",
    "https://swapi.co/api/people/38/",
    "https://swapi.co/api/people/39/",
    "https://swapi.co/api/people/42/",
    "https://swapi.co/api/people/60/",
    "https://swapi.co/api/people/61/",
    "https://swapi.co/api/people/66/",
    "https://swapi.co/api/people/35/"
    ],
    "films": [
    "https://swapi.co/api/films/5/",
    "https://swapi.co/api/films/4/",
    "https://swapi.co/api/films/6/",
    "https://swapi.co/api/films/3/"
    ],
    "created": "2014-12-10T11:52:31.066000Z",
    "edited": "2014-12-20T20:58:18.430000Z",
    "url": "https://swapi.co/api/planets/8/"
    },
    {
    "name": "Coruscant",
    "rotation_period": "24",
    "orbital_period": "368",
    "diameter": "12240",
    "climate": "temperate",
    "gravity": "1 standard",
    "terrain": "cityscape, mountains",
    "surface_water": "unknown",
    "population": "1000000000000",
    "residents": [
    "https://swapi.co/api/people/34/",
    "https://swapi.co/api/people/55/",
    "https://swapi.co/api/people/74/"
    ],
    "films": [
    "https://swapi.co/api/films/5/",
    "https://swapi.co/api/films/4/",
    "https://swapi.co/api/films/6/",
    "https://swapi.co/api/films/3/"
    ],
    "created": "2014-12-10T11:54:13.921000Z",
    "edited": "2014-12-20T20:58:18.432000Z",
    "url": "https://swapi.co/api/planets/9/"
    },
    {
    "name": "Kamino",
    "rotation_period": "27",
    "orbital_period": "463",
    "diameter": "19720",
    "climate": "temperate",
    "gravity": "1 standard",
    "terrain": "ocean",
    "surface_water": "100",
    "population": "1000000000",
    "residents": [
    "https://swapi.co/api/people/22/",
    "https://swapi.co/api/people/72/",
    "https://swapi.co/api/people/73/"
    ],
    "films": [
    "https://swapi.co/api/films/5/"
    ],
    "created": "2014-12-10T12:45:06.577000Z",
    "edited": "2014-12-20T20:58:18.434000Z",
    "url": "https://swapi.co/api/planets/10/"
    },
    {
    "name": "Geonosis",
    "rotation_period": "30",
    "orbital_period": "256",
    "diameter": "11370",
    "climate": "temperate, arid",
    "gravity": "0.9 standard",
    "terrain": "rock, desert, mountain, barren",
    "surface_water": "5",
    "population": "100000000000",
    "residents": [
    "https://swapi.co/api/people/63/"
    ],
    "films": [
    "https://swapi.co/api/films/5/"
    ],
    "created": "2014-12-10T12:47:22.350000Z",
    "edited": "2014-12-20T20:58:18.437000Z",
    "url": "https://swapi.co/api/planets/11/"
    }
    ]
    }
    */
   
}
