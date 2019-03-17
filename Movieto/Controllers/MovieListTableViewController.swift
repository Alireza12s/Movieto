import Alamofire
import UIKit



class MovieListTableViewController: UITableViewController {
    
    var array = [ResultItems]()
    var dtatFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Result.plist")
    
    let movieURL = "http://image.tmdb.org/t/p/w92/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadResult()
        
        
        tableView.tableFooterView = UIView()//delete the empty rows in tableview
        
        //Register Custom Cell to use later
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        
        //reload data table to empty the older data and put new data 
        tableView.reloadData()
    }
    
    
    
    
    //Mark: Load Result Data
    func loadResult(){
        if let data = try? Data(contentsOf: dtatFilePath!){
            let decoder = PropertyListDecoder() 
            do {
                self.array = try decoder.decode([ResultItems].self, from: data)
            } catch {
                print("Error decoding item array,\(error)")
            }
            
        }
        
    }
    
    // MARK: - Table view data source
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 * array.count
        
    }
    
    //Set the height of the custom cells depends on their number of lines
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 150
        return UITableView.automaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = Int(indexPath.row / 2)
        
        if indexPath.row % 2 == 0{
         //Generate custom cells and put result datas there
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! CustomTableViewCell
            
            cell.nameLabel.text = self.array[index].movieName
            
            cell.nameLabel!.font = UIFont.systemFont(ofSize: 11.0)
            
            cell.dateLabel.text = self.array[index].releaseDate
            
            //get image from path if there is a path
            if let imagePath = array[index].posterPath {
            
                let url = movieURL + imagePath
            Alamofire.request(url, method: .get)
                .validate()
                .responseData(completionHandler: { (responseData) in
                    
                    cell.posterImage.image = UIImage(data: responseData.data!)
                    print("Image downloaded")
                })
            }
            
            
            return cell
            
        } else {
            //Make a normal cell for full overview
            let cell = tableView.dequeueReusableCell(withIdentifier: "OverviewCell", for: indexPath)
            
            cell.textLabel!.numberOfLines = 0
            
            cell.textLabel!.lineBreakMode = .byWordWrapping
            
            cell.textLabel!.font = UIFont.systemFont(ofSize: 14.0)
            
            cell.textLabel?.text = array[index].fullOverview
            
            cell.textLabel?.textColor = .white
            cell.textLabel?.backgroundColor = UIColor(red:0.14, green:0.48, blue:0.63, alpha:1.0)
            cell.backgroundColor = UIColor(red:0.14, green:0.48, blue:0.63, alpha:1.0)
            
            return cell
        }
    }
    
    //Unselect the selected cells because it wasn't necessary
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
}


