import Alamofire
import UIKit
import RxAlamofire



class MovieListTableViewController: UITableViewController {
    
    var array = [ResultItems]()
    var dtatFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Result.plist")
    
    let movieURL = "http://image.tmdb.org/t/p/w92/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadResult()
        
        
        //MARK: Register Custom Cell
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
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
                return array.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! CustomTableViewCell
        
        cell.overviewText.text = array[indexPath.row].fullOverview
        cell.nameLabel.text = self.array[indexPath.row].movieName
        cell.dateLabel.text = self.array[indexPath.row].releaseDate
        
        let imagePath = array[indexPath.row].poterPath
            
            do {
                let url = movieURL + imagePath
            Alamofire.request(url, method: .get)
                .validate()
                .responseData(completionHandler: { (responseData) in
                    
                   try? cell.posterImage.image = UIImage(data: responseData.data!)
                    print("Image downloaded")
                    })
                } catch {
                    print("Error downloading image,\(error)")
                }

        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.array = []
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.array)
            try data.write(to: self.dtatFilePath!)
        } catch {
            print("Error Encoding itemArray, \(error)")
        }
    }
    
    
}


