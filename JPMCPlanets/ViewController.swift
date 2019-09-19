//
//  ViewController.swift
//  JPMCPlanets
//
//  Created by stephen eshelman on 9/16/19.
//  Copyright © 2019 stephen eshelman. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController
{

   override func viewDidLoad()
   {
      super.viewDidLoad()
      // Do any additional setup after loading the view.
      
      let planetsUrl = URL(string:"https://swapi.co/api/planets/")!
      let task = URLSession.shared.dataTask(with: planetsUrl)
      {(data, response, error) in
         //print(data!)
         //print(response!)
         //print(error!)
         
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
                        }
                     }
                  }
                  //print(results[0])
               }
            }
         }
         catch let error as NSError
         {
            print("\(error)")
         }
      }

      task.resume()
   }

}

