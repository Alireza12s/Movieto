//
//  MovieListTableViewController.swift
//  Movieto
//
//  Created by ali on 3/15/19.
//  Copyright © 2019 com.alireza. All rights reserved.
//

import UIKit

class MovieListTableViewController: UITableViewController {
    
    let array = [ResultItems]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Register Custom Cell
        tableView.register(UINib(nibName: "", bundle: nil), forCellReuseIdentifier: "ResultCell")
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! CustomTableViewCell
        
        cell.textView.text = array[indexPath.row].fullOverview
        
        if let imagePath = array[indexPath.row].poterPath{
        
//        cell.posterImageView = getPoster(path: imagePath )
            
        }
        
        cell.nameAndDateLabel.text! = array[indexPath.row].movieName + "|" + array[indexPath.row].releaseDate
        
        return cell
    }
    
    
    
    //MARK: Get Poster
    func getPoster(path: String) /*-> UIImageView*/ {
    
    
    
    
    }
    

}
