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
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    
    //MARK: Flow Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModel()
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
//        filteredSuggestedSearchFoods = suggestedSearchFoods.filter({(food: String) -> Bool
//            in
//            var foodMatch = food.rangeOfString(searchText)
//            return foodMatch != nil
//        })
        //Can you do the above with a trailing closure? - YES, IT APPEAR YOU CAN!

//        filteredSuggestedSearchFoods = suggestedSearchFoods.filter(){food in food.rangeOfString(searchText) != nil}
        
        //Maybe even more concise?!? - YES! FTW.
        
        filteredSuggestedSearchFoods = suggestedSearchFoods.filter(){$0.rangeOfString(searchText) != nil}
    }

    //MARK: UITableView Data Source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kSuggestedFoodCell) as UITableViewCell
        if searchController.active {
            cell.textLabel?.text = filteredSuggestedSearchFoods[indexPath.row]
        } else {
            cell.textLabel?.text = suggestedSearchFoods[indexPath.row]
        }
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return filteredSuggestedSearchFoods.count
        } else {
            return suggestedSearchFoods.count
        }
    }
    
    //MARK: UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        let selectedScopeButtonIndex = searchController.searchBar.selectedScopeButtonIndex
        filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
        tableView.reloadData()
    }
    
    //MARK: UISearchBar Delegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        makeRequest(searchBar.text)
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
//MARK: Defines
let kDefaultSuggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicen breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
let kAppID = "e26c0bef"
let kAppKey = "77b95827071b8f2193c8475820238287"

//MARK: Globals
var suggestedSearchFoods: [String] = []
var filteredSuggestedSearchFoods: [String] = []

func setupModel() {
    suggestedSearchFoods = kDefaultSuggestedSearchFoods
}

func makeRequest(searchString: String) {
//EXAMPLE OF AN HTTP GET REQUEST
//    let url = NSURL(string: "https://api.nutritionix.com/v1_1/search/"+searchString+"?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId="+kAppID+"&appKey="+kAppKey)
//    let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
//        var stringForData = NSString(data: data, encoding: NSUTF8StringEncoding)
//        println(stringForData)
//        println(response)
//    })
//    task.resume()
    
//IMPLEMENTING USING AN HTTP POST REQUEST
    
}

