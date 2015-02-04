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
    let kSearchBarHeight: CGFloat = 44.0
    let kSuggestedFoodCell = "Suggested Food Cell"
    let model = FTModel()
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    
    //MARK: Flow Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
//        searchController.searchBar.frame = CGRectMake(searchController.searchBar.frame.origin.x,
//                                                      searchController.searchBar.frame.origin.y,
//                                                      searchController.searchBar.frame.size.width,
//                                                      kSearchBarHeight)
        searchController.searchBar.frame.size.height = kSearchBarHeight //shouldn't this do the same thing?
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = scopeButtonTitles
        searchController.searchBar.delegate = self
        definesPresentationContext = true
    }
    
    //MARK: Helper Functions
    func filterContentForSearch(searchText: String, scope: Int) {
//        model.filteredSuggestedSearchFoods = model.suggestedSearchFoods.filter({(food: String) -> Bool
//            in
//            var foodMatch = food.rangeOfString(searchText)
//            return foodMatch != nil
//        })
        //Can you do the above with a trailing closure? - YES, IT APPEAR YOU CAN!

//        model.filteredSuggestedSearchFoods = model.suggestedSearchFoods.filter(){food in food.rangeOfString(searchText) != nil}
        
        //Maybe even more concise?!? - YES! FTW.
        
        model.filteredSuggestedSearchFoods = model.suggestedSearchFoods.filter(){$0.rangeOfString(searchText) != nil}

    }

    //MARK: UITableView Data Source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kSuggestedFoodCell) as UITableViewCell
        if searchController.active {
            cell.textLabel?.text = model.filteredSuggestedSearchFoods[indexPath.row]
        } else {
            cell.textLabel?.text = model.suggestedSearchFoods[indexPath.row]
        }
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return model.filteredSuggestedSearchFoods.count
        } else {
            return model.suggestedSearchFoods.count
        }
    }
    
    //MARK: UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        let selectedScopeButtonIndex = searchController.searchBar.selectedScopeButtonIndex
        filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
        tableView.reloadData()
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

//MARK: - Model
//MARK: Classes
class FTModel {
    //MARK: Defines
    let kDefaultSuggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicen breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]

    //MARK: Globals
    var suggestedSearchFoods: [String] = []
    var filteredSuggestedSearchFoods: [String] = []
    
    //MARK: Init
    init() {
        suggestedSearchFoods = kDefaultSuggestedSearchFoods
    }
    
}

