# JPMCPlanets
Documentation/Workflow:

Summary:
Perform HTTP request - https://swapi.co/api/planets/?page=3 and display planets response in a list
Persist request to a file, read, and display as "last" request
Upon selection of planet from list show additional information

Discussion:
Solution uses a grouped table view controller with a "current" and "last" section
Embedded in a navigation controller
Selections perfrom a segue to another table view controller with the selected planet info

Details:
Query website on startup ( viewDidLoad ), PlanetsTableViewController
Capture and parse JSON into a list of planet names and a dictioary of planet name to dictioary of planet info
Read the last queried planets list from file, this is the JSON that was returned from the query
parse JSON into a list of planet names and a dictioary of planet name to dictioary of planet info
Main table view controller has 2 sections, one for the current planet list and one for the last queried list ( from file )
Selections from table view controller ( which is embedde in a navigation contoller ) navigate to PlanetInfoTableViewController
In prepare for segue the selected planet dictionary is set on the destination view controller which implements useswPlanetInfo protocol


Suggestions for improvement:
add UI and network unit tests
localization
add images/video
add option to fetch other pages
ability to query for more pages
more error checking
convert to swiftui
perform file read in another thread
indicate "no last"
add navigation item button fpr "next page"
