import Alamofire
import UIKit
import Alamofire
import SwiftyJSON


class SearchTableViewController: UITableViewController{
    
    
    var itemArray = [QueryItems]()
    var queriesArray = [QueryItems]()
    var resultArray = [ResultItems]()
    
    //Constants
    var movieName: String = ""
    let APIKey: String = "f7128111cfbf8f7d2850e8ba64058948"
    let movieURL: String = "https://api.themoviedb.org/3/search/movie?api_key="
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("SearchHistory.plist")
    
    
    //Mark: Instance Variables
    
    
    
    //Pre-linked IBOutlets
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        loadItems()
        
        
    }
    
    
    
    //MARK: Search function
    /***************************************************************/
    

    
    
    //MARK: Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if queriesArray.count == 0{
            return 0
        } else {
            return queriesArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QueryHistoryCell", for: indexPath)
        
        
        let item = queriesArray[indexPath.row]
        
        cell.textLabel?.text = item.text
        
        return cell;
    }
    
    
    
    
    //MARK: TableView Delegate Mothods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
    }
    
    
    
    
    //MARK: Networking
    /***************************************************************/
    
    //MARK: Make URL
    func makeURL(MovieName name: String) -> String{
        return movieURL + APIKey + "&language=en-US&query=" + name + "&page=1&include_adult=false"
    }
    
    
    //MARK: Get Movie Data
    func getMovieData(name: String){
        
        let url: String = makeURL(MovieName: name)
        
                Alamofire.request(url,method: .get).responseJSON{
                    response in
                    if response.result.isSuccess {
                        print("Success!Got the Movie data")
                        var item = QueryItems()
                        item.text = name
                        self.itemArray.append(item)
        
                        let movieJSON: JSON = JSON(response.result.value!)
                        print(movieJSON)
                        updateMovieData(json: movieJSON)
                    } else {
                        print("Error \(String(describing: response.result.error))")
                        print("Connection Issue")
                        //TODO: Make Alert For Connection Issue
                    }
        
        saveItems()
        
    }
    
    
        
    
    
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //We parse our Recieved Json here and update uiTableview cell to show our result
    func updateMovieData(json: JSON){
        
        let resultItem = ResultItems()
        
            for i in 0 ..< 20{
                let jsonItem = json["results"][i]
                
                resultItem.fullOverview = jsonItem["overview"].stringValue
                
                resultItem.movieName = jsonItem["title"].stringValue
                
                resultItem.poterPath = jsonItem["poster_path"].stringValue
                
                resultItem.releaseDate = jsonItem["release_date"].stringValue
                
                resultArray.append(resultItem)
            }
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
    
    
    
    

    
    
    
    //MARK: - Change Movie Delegate methods
    /***************************************************************/
    func userEnteredANewMovieName(movie: String) {
        
        //        let params: [String : String] = ["q" : city, "appid" : APP_ID]
        //        getMovieData(url: WEATHER_URL, parameters: params)
        
    }
    
    //Write the userEnteredANewCityName Delegate method here:
    
    
    //MARK: Model Manupulation Method
    
    
    func saveItems(){
        
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error Encoding itemArray, \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadItems(){
        
        if let data = try? Data(contentsOf: dataFilePath!){
        let decoder = PropertyListDecoder()
        do {
            itemArray = try decoder.decode([QueryItems].self, from: data)
        } catch {
            print("Error decoding item array,\(error)")
        }
        
        }
        
        self.tableView.reloadData()
    }
    
    
    
    }
    
}


extension SearchTableViewController: UISearchBarDelegate{
    
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.movieName = searchBar.text!
        getMovieData(name: movieName)
        
        
        if searchBar.text?.count == 0 {
            self.queriesArray = self.itemArray
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        if searchText.count != 0{
            
            let key = searchText
            let filteredStrings = self.itemArray.filter({(item: QueryItems) -> Bool in
                
                let stringMatch = item.text.lowercased().range(of: key.lowercased())
                return stringMatch != nil ? true : false
            })
            
            self.queriesArray = filteredStrings
            self.tableView.reloadData()
            
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Cancel")
    }
    
}
