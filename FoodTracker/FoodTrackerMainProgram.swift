//
//  FoodTrackerMainProgram.swift
//  FoodTracker
//
//  Created by Dan Manteufel on 2/3/15.
//  Copyright (c) 2015 ManDevil Programming. All rights reserved.
//

import UIKit

//MARK: - Main View Controller
class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    //MARK: Defines
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    
    //MARK: Flow Functions
    
    //MARK: Helper Functions

    //MARK: UITableView Data Source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    //MARK: UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
}

//MARK: - Detail View Controller
class DetailVC: UIViewController {
    //MARK: Defines
    
    //MARK: Properties
    @IBOutlet weak var textView: UITextView!
    
    //MARK: Flow Functions
    @IBAction func eatItBBItemPressed(sender: AnyObject) {
        
    }
    
    //MARK: Helper Functions
    
    
}
