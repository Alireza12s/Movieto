import Alamofire
import UIKit
import SwiftyJSON
import Network


class SearchTableViewController: UITableViewController{
    
    @IBOutlet var searchBar: UISearchBar!
    
    var itemArray = [QueryItems]()
    var queriesArray = [QueryItems(),QueryItems(),QueryItems(),QueryItems(),QueryItems(),QueryItems(),QueryItems(),QueryItems(),QueryItems(),QueryItems()]
    var resultArray = [ResultItems]()
    
    //Constants
    var movie: String = ""
    
    let APIKey: String = "f7128111cfbf8f7d2850e8ba64058948"
    
    let movieURL: String = "https://api.themoviedb.org/3/search/movie?api_key="
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("SearchHistory.plist")
    
    let dataFilePath2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Result.plist")
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadItems()
        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableFooterView = UIView()

        fixSuggestions()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        resultArray = []
        saveResult()
        checkNtework()
        self.tableView.reloadData()
    }
    
    //MARK: Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if queriesArray.count>10{
            return 10
        } else {
            return queriesArray.count
            print(queriesArray.count)
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
        
        if let movieName = self.tableView.cellForRow(at: indexPath)?.textLabel?.text {
            getMovieData(name: movieName)
            
        } else {
            print("Error empty cell")
        }
        
        
        
        
    }
    
    
    //MARK: Networking
    /***************************************************************/
    
    //MARK: Make URL
    func makeURL(MovieName name: String) -> String{
        return movieURL + APIKey + "&language=en-US&query=" + name + "&page=1&include_adult=false"
    }
    
    
    //MARK: Get Movie Data
    func getMovieData(name: String){
        self.movie = name
        let formattedName = String(name.replacingOccurrences(of: " ", with: "%20"))
        
        let url: String = makeURL(MovieName: formattedName)
        
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if response.result.isSuccess {
                print("Success!Got the Movie data")
                let item = QueryItems()
                item.text = name
                
                
                self.itemArray.append(item)
                
                let movieJSON: JSON = JSON(response.result.value!)
                self.updateMovieData(json: movieJSON)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                
                
                let connectionAlert = UIAlertController(title: "Connection Issue", message: "Please Check Your Internet Connection", preferredStyle: .alert)
                
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                connectionAlert.addAction(alertAction)
                
                self.present(connectionAlert, animated: true, completion: nil)
            }
            
            self.saveItems()
            
        }
        
        
    }
    
    
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //We parse our Recieved Json here and save results
    func updateMovieData(json: JSON){
        
        let numberOfResults = json["results"].count
        if numberOfResults  == 0 {
            
            let alert = UIAlertController(title: "No Movie Found", message: "No Results Found For \" \(movie) \" ", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default){ (_) in
                
                self.searchBar.text = ""
                
                self.searchBar.endEditing(true)
                
                self.searchBar.showsCancelButton = false
                
                self.fixSuggestions()
            }
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        } else {
        for i in 0 ..< numberOfResults{
            let resultItem = ResultItems()
            
            resultItem.fullOverview = json["results"][i]["overview"].stringValue
            
            resultItem.movieName = json["results"][i]["title"].stringValue
            
            resultItem.posterPath = json["results"][i]["poster_path"].stringValue
            
            resultItem.releaseDate = json["results"][i]["release_date"].stringValue
            
            resultArray.append(resultItem)
        }
        saveResult()
        performSegue(withIdentifier: "SearchSegue", sender: nil)
        }
    }
    
    
    //MARK: Save Search Result
    
    func saveResult(){
        
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(resultArray)
            try data.write(to: dataFilePath2!)
        } catch {
            print("Error Encoding itemArray, \(error)")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchSegue"{
            let vC = segue.destination as! MovieListTableViewController
            vC.dtatFilePath = dataFilePath2
        }
    }
    
    
    //MARK: Model Manupulation Method
    
    
    func saveItems(){
        itemArray = Array(Set<QueryItems>(itemArray))
        
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
    
    func fixSuggestions(){
        loadItems()
        if itemArray.count > 9{
            self.queriesArray = Array(self.itemArray.suffix(from: self.itemArray.count - 10))
        }
//         else {
//            for i in 0..<self.queriesArray.count{
//                self.queriesArray.append(self.itemArray[self.itemArray.count - 1 - i])
//            }
//        }
        self.tableView.reloadData()
    }
    
    
    func checkNtework(){
        
        if #available(iOS 12.0, *) {
            let monitor = NWPathMonitor()
            
            monitor.pathUpdateHandler = { (path) in
                
                if path.status == .satisfied {
                    
                    print("We're connected!")
                    
                } else {
                    
                    print("No connection.")
                    let alert = UIAlertController(title: "Check Your Connection", message: "You're Not Connected To The Internet", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "OK", style: .default){(action) in
                        
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                // Checking for setting is opened or not
                                print("Setting is opened: \(success)")
                            })
                        }
                        
                    }
                    
                    alert.addAction(action)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            
            let queue = DispatchQueue(label: "Monitor")
            
            monitor.start(queue: queue)
        }
    }
    
    
    
}

//MARK: SearchBar Delegate Methods
extension SearchTableViewController: UISearchBarDelegate{
    
    
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.fixSuggestions()
        searchBar.showsCancelButton = true
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        if searchBar.text == ""{
            let emptyNameAlert = UIAlertController(title: "Empty Name", message: "Please Enter a Movie Name", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
            
            emptyNameAlert.addAction(action)
            
            self.present(emptyNameAlert, animated: true, completion: nil)
        } else {
            
            
            
            DispatchQueue.main.async {
                
                self.movie = searchBar.text!
                
                self.getMovieData(name: self.movie)
                
            }
            
        }
        
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0 {
            self.fixSuggestions()
        }else if  searchText.count != 0{
            
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
        
        searchBar.showsCancelButton = false
        
        self.queriesArray = self.itemArray
        
        searchBar.text = ""
        
        self.fixSuggestions()
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
}
