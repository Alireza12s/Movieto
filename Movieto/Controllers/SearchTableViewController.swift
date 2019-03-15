
import Alamofire
import UIKit
import Alamofire
import SwiftyJSON
import CoreData


class SearchTableViewController: UITableViewController{
    
    
    var itemArray = [Item]()
    
    //Constants
    let Movie_URL = ""
    let APP_ID = ""
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("SearchHistory.plist")
    
    
    //Mark: Instance Variables
//    let locationManager = CLLocationManager()
    
    
    
    //Pre-linked IBOutlets

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }
    
    
    
    //MARK: Search function
    /***************************************************************/

    func search(array: [Item],key: String) -> [Item]{
        
        
//        let filteredStrings = array.filter({(item.text: String) -> Bool in
//
//            let stringMatch = item.text.lowercased().range(of: key.lowercased())
//            return stringMatch != nil ? true : false
//        })
        
        return filteredStrings
    }
    
    
    //MARK: Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = .none
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell;
    }
    
    
    
    
    //MARK: TableView Delegate Mothods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
    //MARK: Networking
    /***************************************************************/
    
    //MARK: Get Movie Data
    func getMovieData(url: String, parameters: [String : String]){
        

        
//        Alamofire.request(url,method: .get, parameters:  parameters).responseJSON{
//            response in
//            if response.result.isSuccess {
//                print("Success!Got the Movie data")
//
//                let weatherJSON: JSON = JSON(response.result.value!)
//                self.updateWeatherData(json: weatherJSON)
//            } else {
//                print("Error \(String(describing: response.result.error))")
//                self.cityLabel.text = "Connection Issues"
//            }
        
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error Encoding itemArray, \(error)")
        }
        
        }
        
        
    
        
    
    
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //We parse our Recieved Json here and update uiTableview cell to show our result
    func updateSearchResult(json: JSON){

//        if let tempResult  = json["main"]["temp"].double {
//
//            wetherDataModel.temperature = Int(tempResult - 273.15)
//            wetherDataModel.city = json["name"].stringValue
//            wetherDataModel.condition = json["weather"][0]["id"].intValue
//            wetherDataModel.weatherIconName = wetherDataModel.updateWeatherIcon(condition: wetherDataModel.condition)
//            updateUIWithWeatherData()
//        } else {
//            cityLabel.text = "Weather Unavailable"
//        }
        
    }
    
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    

    //MARK: Finall Result
    func updateUIWithFinallResult(){
//        cityLabel.text = wetherDataModel.city
//        temperatureLabel.text = "\(wetherDataModel.temperature)°"
//        weatherIcon.image = UIImage(named: wetherDataModel.weatherIconName)
        
    }
    //MARK:
    
    
    
    
//
//    //MARK: - Location Manager Delegate Methods
//    /***************************************************************/
//
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location = locations[locations.count - 1]
//        if location.horizontalAccuracy > 0{
//            locationManager.stopUpdatingLocation()
//            locationManager.delegate = nil
//
//            print("longitude = \(location.coordinate.longitude)  ,  latitude = \(location.coordinate.latitude)")
//
//
//
//            let latitude = String(location.coordinate.latitude)
//            let longitude = String(location.coordinate.longitude)
//            let params: [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
//
//            getWeatherData(url: WEATHER_URL, parameters: params)
//
//
//        }
//    }
    
    
    
    
    //MARK: - Change Movie Delegate methods
    /***************************************************************/
    func userEnteredANewMovieName(movie: String) {
        
//        let params: [String : String] = ["q" : city, "appid" : APP_ID]
//        getMovieData(url: WEATHER_URL, parameters: params)
        
    }
    
    //Write the userEnteredANewCityName Delegate method here:
    
    
    //MARK: Model Manupulation Method
    
    
    func saveItems(){
        
        
        self.tableView.reloadData()
        
    }
    
    func loadItems(){
        
        
    }
    
    
    


}


extension SearchTableViewController: UISearchBarDelegate{
    
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        
        loadItems(with: request)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let resultArray = self.search(array: itemArray, key: searchBar.text!)
        
        if searchBar.text?.count == 0{
            
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
    
    
}
