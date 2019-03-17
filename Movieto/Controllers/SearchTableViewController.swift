import Alamofire
import UIKit
import SwiftyJSON
import Network


class SearchTableViewController: UITableViewController{
    
    @IBOutlet var searchBar: UISearchBar!
    
    var itemArray = [QueryItems]()
    var queriesArray = [QueryItems(),QueryItems(),QueryItems(),QueryItems(),QueryItems(),QueryItems(),QueryItems(),QueryItems(),QueryItems(),QueryItems()]
    var resultArray = [ResultItems]()
    
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

        tableView.tableFooterView = UIView()//delete empty rows of table view

        fixSuggestions()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {//empty old result data and check network when app did appear
        resultArray = []
        saveResult()
        checkNtework()
        self.tableView.reloadData()
    }
    
    //MARK: Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if queriesArray.count>10{//if number of search histories are more than 10 it makes 10 cells else make cell to number of search histories
            return 10
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
        let cell = self.tableView.cellForRow(at: indexPath)
        if let movieName = cell?.textLabel?.text {
            if !(cell?.textLabel?.text == " " || (cell?.textLabel?.text)! == ""){
                
                getMovieData(name: movieName)

            } else {
                cell?.isSelected = false
            }
        }
        
        
        
        
    }
    
    
    //MARK: Networking
    /***************************************************************/
    
    //MARK: Make URL
    func makeURL(MovieName name: String) -> String{//make URL for sending API request
        return movieURL + APIKey + "&language=en-US&query=" + name + "&page=1&include_adult=false"
    }
    
    
    //MARK: Get Movie Data
    func getMovieData(name: String){
        self.movie = name
        let encodedMovieName = name.encodeURIComponent()//encode the movie name to search through API request
        
        let url: String = makeURL(MovieName: encodedMovieName!)
        
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if response.result.isSuccess {
                print("Success!Got the Movie data")
                let item = QueryItems()
                item.text = name
                
                
                self.itemArray.append(item)//append movie name to search history
                
                let movieJSON: JSON = JSON(response.result.value!)//send json result to pbe parsed
                self.updateMovieData(json: movieJSON)
                
            } else {
                print("Error \(String(describing: response.result.error))")//if network has a problem or in this special case even if vpn is dsconnected it makes an alert to tell user check your connection
                
                
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
        
        let numberOfResults = json["results"].count//get number of answers
        if numberOfResults  == 0 {//check that there is an answer for search or not
            //if there is no answer we tell user movie name is wrong with alert
            let alert = UIAlertController(title: "No Movie Found", message: "No Results Found For \" \(movie) \" ", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default){ (_) in
                //when user clicks ok button in alert the search bar will empty and cancel button will disappear
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
        //save the results in format of Model in phone
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(resultArray)
            try data.write(to: dataFilePath2!)
        } catch {
            print("Error Encoding itemArray, \(error)")
        }
        
    }
    //send result file path to movie list VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchSegue"{
            let vC = segue.destination as! MovieListTableViewController
            vC.dtatFilePath = dataFilePath2
        }
    }
    
    
    //MARK: Model Manupulation Method
    
    //Save the queries in the phone
    func saveItems(){
        itemArray = Array(Set<QueryItems>(itemArray))//delete repeated datas
        itemArray = itemArray.filter({ $0.text != "" && $0.text != " "})
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error Encoding itemArray, \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    //load queries from phone
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
        
        self.tableView.reloadData()
    }
    
    //MARK: Check Internet Connection
    func checkNtework(){
        //this code only available in ios 12 and later
        //because our app needs intrnet it checks the internet connection and if it's off it sends user to setting that they could turn on WiFi\Cellular
        if #available(iOS 12.0, *) {
            let monitor = NWPathMonitor()
            
            monitor.pathUpdateHandler = { (path) in
                
                if path.status == .satisfied {
                    
                    print("We're connected!")
                    
                } else {
                    
                    print("No connection.")//make alert to tell user about internet connection problem
                    let alert = UIAlertController(title: "Check Your Connection", message: "You're Not Connected To The Internet", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "OK", style: .default){(action) in
                        
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        //by pressing ok button users will sends to setting to fix the connection
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
            
            let queue = DispatchQueue(label: "Monitor")// in every moment in program it checks internet connection in search screeen
            
            monitor.start(queue: queue)
        }
    }
    
    
    
}

//MARK: SearchBar Delegate Methods
extension SearchTableViewController: UISearchBarDelegate{
    
    
    
    
    //MARK: SearchBar Text Did Begin Changing
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.fixSuggestions()
        searchBar.showsCancelButton = true//it makes suggestions ready and will show cancell button
        
    }
    
    //MARK: Search Button Clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //if user doesn't ener a movie name and the textfiels was only space character it will alert to him that you should enter a name
        if searchBar.text == " "{
            let emptyNameAlert = UIAlertController(title: "Empty Name", message: "Please Enter a Movie Name", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
            
            emptyNameAlert.addAction(action)
            
            self.present(emptyNameAlert, animated: true, completion: nil)
        } else {//it searches the name that user entered
            
            
            
            DispatchQueue.main.async {
                
                self.movie = searchBar.text!
                
                self.getMovieData(name: self.movie)
                
            }
            
        }
        
        
    }
    
    //MARK: Search Text Did Change
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0 {
            self.fixSuggestions()
        }else if  searchText.count != 0{
            
            let key = searchText //filter the strings in search history that has the key(text that user entered now)
            let filteredStrings = self.itemArray.filter({(item: QueryItems) -> Bool in
                
                let stringMatch = item.text.lowercased().range(of: key.lowercased())
                return stringMatch != nil ? true : false
            })
            
            self.queriesArray = filteredStrings
            self.tableView.reloadData()
            
        }
    }
    
    
    //MARK: Cancel Button Clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //When we click on cancel button then
        searchBar.showsCancelButton = false // cancell button will hide
        
        self.queriesArray = self.itemArray //suggestions will be reset to 10 last search
        
        searchBar.text = "" //empty serach bar textfield
        
        self.fixSuggestions()
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder() //hide keyboard
        }
    }
    
}


//MARK: Encode Text
extension String {
    func encodeURIComponent() -> String? {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-_.!~*'()")
        return self.addingPercentEncoding(withAllowedCharacters: characterSet)
    }
}
