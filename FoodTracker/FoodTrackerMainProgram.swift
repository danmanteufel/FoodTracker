//
//  FoodTrackerMainProgram.swift
//  FoodTracker
//
//  Created by Dan Manteufel on 2/3/15.
//  Copyright (c) 2015 ManDevil Programming. All rights reserved.
//

import UIKit
import CoreData

//MARK: - Main View Controller
class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    //MARK: Defines
    let kSearchBarHeight: CGFloat = 44.0
    let kSuggestedFoodCell = "Suggested Food Cell"
    let kMainToDetailSegue = "Main To Detail Segue"
    enum ScopeButtonTitle: Int {
        case Recommended = 0
        case SearchResults = 1
        case Saved = 2
    }
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    var model = FTModel()
    var favoritedUSDAItems: [USDAItem] = []
    var filteredFavoritedUSDAItems: [USDAItem] = []
    
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
    
    override func viewWillAppear(animated: Bool) {//Swift docs put this in the init and deinit functions
        super.viewWillAppear(animated)
        model.addObserver(self, forKeyPath: "apiResultsChanged", options: .allZeros, context: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeObserver(self, forKeyPath: "apiResultsChanged")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kMainToDetailSegue {
            if sender != nil {
                let detailVC = segue.destinationViewController as DetailVC
                detailVC.usdaItem = sender as? USDAItem
            }
        }
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
        switch ScopeButtonTitle(rawValue: scope)! {
            case .Recommended:
                model.filteredSuggestedSearchFoods = model.suggestedSearchFoods.filter(){$0.rangeOfString(searchText) != nil}
            case .Saved:
                filteredFavoritedUSDAItems = favoritedUSDAItems.filter(){$0.name.rangeOfString(searchText) != nil}
            default:
                break
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "apiResultsChanged" {
            println("Table Reloaded in Observer")
            dispatch_async(dispatch_get_main_queue()) {self.tableView.reloadData()}
            //tableView.reloadData()//Somehow this isn't on the main queue
        }
    }
    
    func requestFavoritedUSDAItems() {
        let fetchRequest = NSFetchRequest(entityName: model.kCDUSDAItem)
        let moc = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        favoritedUSDAItems = moc?.executeFetchRequest(fetchRequest, error: nil) as [USDAItem]
    }

    //MARK: UITableView Data Source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kSuggestedFoodCell) as UITableViewCell
        switch ScopeButtonTitle(rawValue: searchController.searchBar.selectedScopeButtonIndex)! {
        case .Recommended:
            if searchController.active {
                cell.textLabel?.text = model.filteredSuggestedSearchFoods[indexPath.row]
            } else {
                cell.textLabel?.text = model.suggestedSearchFoods[indexPath.row]
            }
        case .SearchResults:
            cell.textLabel?.text = model.apiSearchForFoods[indexPath.row].name
        default:
            if searchController.active {
                cell.textLabel?.text = filteredFavoritedUSDAItems[indexPath.row].name
            } else {
                cell.textLabel?.text = favoritedUSDAItems[indexPath.row].name
            }
        }

        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch ScopeButtonTitle(rawValue: searchController.searchBar.selectedScopeButtonIndex)! {
        case .Recommended:
            if searchController.active {return model.filteredSuggestedSearchFoods.count}
            return model.suggestedSearchFoods.count
        case .SearchResults:
            return model.apiSearchForFoods.count
        default:
            if searchController.active {return filteredFavoritedUSDAItems.count}
            return favoritedUSDAItems.count
        }
    }
    
    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch ScopeButtonTitle(rawValue: searchController.searchBar.selectedScopeButtonIndex)! {
        case .Recommended:
            var searchFoodName: String
            if searchController.active {
                searchFoodName = model.filteredSuggestedSearchFoods[indexPath.row]
            } else {
                searchFoodName = model.suggestedSearchFoods[indexPath.row]
            }
            searchController.searchBar.selectedScopeButtonIndex = ScopeButtonTitle.SearchResults.rawValue
            searchController.active = true
            model.makeRequest(searchFoodName)
        case .SearchResults:
            self.performSegueWithIdentifier(kMainToDetailSegue, sender: nil)
            let idValue = model.apiSearchForFoods[indexPath.row].idValue
            model.saveUSDAItemForId(idValue)
            searchController.searchBar.selectedScopeButtonIndex = ScopeButtonTitle.Saved.rawValue
            requestFavoritedUSDAItems()
            tableView.reloadData()
        case .Saved:
            var usdaItem: USDAItem?
            if searchController.active {
                usdaItem = filteredFavoritedUSDAItems[indexPath.row]
            } else {
                usdaItem = favoritedUSDAItems[indexPath.row]
            }
            performSegueWithIdentifier(kMainToDetailSegue, sender: usdaItem)
        default:
            break
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
        searchController.searchBar.selectedScopeButtonIndex = ScopeButtonTitle.SearchResults.rawValue
        model.makeRequest(searchBar.text)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if ScopeButtonTitle(rawValue: selectedScope)! == .Saved {requestFavoritedUSDAItems()}
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        searchController.searchBar.selectedScopeButtonIndex = ScopeButtonTitle.Recommended.rawValue
        tableView.reloadData()
    }
}

//MARK: - Detail View Controller
class DetailVC: UIViewController {
    //MARK: Defines
    
    //MARK: Properties
    @IBOutlet weak var textView: UITextView!
    var usdaItem: USDAItem?
    
    //MARK: Flow Functions
    @IBAction func eatItBBItemPressed(sender: AnyObject) {
        
    }
    
    //MARK: Helper Functions
    
    
}

//MARK: - Model
class FTModel: NSObject {
    //MARK: Defines
    let kDefaultSuggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicken breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
    let kAppID = "e26c0bef"
    let kAppKey = "77b95827071b8f2193c8475820238287"
    let kAPIHits = "hits"
    let kAPIID = "_id"
    let kAPIFields = "fields"
    let kAPIItemNameField = "item_name"
    let kAPIBrandName = "brand_name"
    let kAPIKeywords = "keywords"
    let kAPIUSDAFields = "usda_fields"
    let kAPIComponentValue = "value"
    let kAPICalciumField = "CA"
    let kAPICarbohydratesField = "CHOCDF"
    let kAPIFatTotalField = "FAT"
    let kAPICholesterolField = "CHOLE"
    let kAPIProteinField = "PROCNT"
    let kAPISugarField = "SUGAR"
    let kAPIVitaminCField = "VITC"
    let kAPIEnergyField = "ENERC_KCAL"
    let kCDUSDAItem = "USDAItem"

    //MARK: Properties
    var suggestedSearchFoods: [String] = []
    var filteredSuggestedSearchFoods: [String] = []
    var apiSearchForFoods: [(name: String, idValue: String)] = [] {
        didSet {
            apiResultsChanged = true
        }
    }
    dynamic var apiResultsChanged = false
    var lastJSONResponse: NSDictionary!
    
    //MARK: Model Functions
    override init() {
        super.init()
        suggestedSearchFoods = kDefaultSuggestedSearchFoods
    }
    
    func makeRequest(searchString: String) {
        //EXAMPLE OF AN HTTP GET REQUEST
        //    let url = NSURL(string: "https://api.nutritionix.com/v1_1/search/"+searchString+"?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId="+kAppID+"&appKey="+kAppKey)
        //    let task = NSURLSession.sharedSession().dataTaskWithURL(url!){ (data, response, error) in
        //        var stringForData = NSString(data: data, encoding: NSUTF8StringEncoding)
        //        println(stringForData)
        //        println(response)
        //    }
        //    task.resume()
    
        //IMPLEMENTING USING AN HTTP POST REQUEST
        var request = NSMutableURLRequest(URL: NSURL(string: "https://api.nutritionix.com/v1_1/search/")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var params = [
            "appId" : kAppID,
            "appKey" : kAppKey,
            "fields" : [kAPIItemNameField, kAPIBrandName, kAPIKeywords, kAPIUSDAFields],
            "limit" : "50",
            "query" : searchString,
            "filters" : [
                "exists" : [
                    kAPIUSDAFields : true]]]
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
    
        var task = session.dataTaskWithRequest(request) { (data, response, errorInRequst) in
            //var stringFromData = NSString(data: data, encoding: NSUTF8StringEncoding)
            var conversionError: NSError?
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &conversionError) as? NSDictionary
            //println(jsonDictionary)
        
            if conversionError != nil {
                let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error in Parsing \(errorString)")
                println(conversionError!.localizedDescription)
            } else {
                if jsonDictionary != nil {
                    self.lastJSONResponse = jsonDictionary!
                    self.apiSearchForFoods = self.jsonAsUSDAIdAndNameSearchResults(jsonDictionary!)
                } else {
                    println("No Results")
                }
            }
        }
        task.resume()
    }

    func jsonAsUSDAIdAndNameSearchResults (json: NSDictionary) -> [(name: String, idValue: String)] {
        var usdaItemsSearchResults: [(name: String, idValue: String)] = []
        var searchResult: (name: String, idValue: String)
        if let results: [AnyObject] = json[kAPIHits] as? [AnyObject] {
            for itemDictionary in results {
                if itemDictionary[kAPIID] != nil {
                    if let fieldsDictionary = itemDictionary[kAPIFields] as? NSDictionary {
                        if let name = fieldsDictionary[kAPIItemNameField] as? String {
                            let idValue = itemDictionary[kAPIID] as String
                            searchResult = (name: name, idValue: idValue)
                            usdaItemsSearchResults += [searchResult]
                        }
                    }
                }
            }
        }
        //println(usdaItemsSearchResults)
        return usdaItemsSearchResults
    }
    
    func saveUSDAItemForId(idValue: String) {
        if let results: [AnyObject] = lastJSONResponse[kAPIHits] as? [AnyObject] {
            for itemDictionary in results {
                if itemDictionary[kAPIID] != nil &&
                   itemDictionary[kAPIID] as String == idValue {
                    let moc = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
                    
                    //Checking for item already in Core Data
                    var requestForUSDAItem = NSFetchRequest(entityName: kCDUSDAItem)
                    let itemDictionaryId = itemDictionary[kAPIID]! as String
                    let predicate = NSPredicate(format: "idValue == %@", itemDictionaryId)
                    requestForUSDAItem.predicate = predicate
                    var error: NSError?
                    var items = moc?.executeFetchRequest(requestForUSDAItem, error: &error)
                    //Also a countForFetchRequest, but we'll need the whole query later
                    if items?.count != 0 {
                        println("Item Already Saved")
                        return
                    }
                    
                    //Writing the new item to Core Data
                    println("Saving to Core Data")
                    let entityDescription = NSEntityDescription.entityForName(kCDUSDAItem, inManagedObjectContext: moc!)
                    let usdaItem = USDAItem(entity: entityDescription!, insertIntoManagedObjectContext: moc!)
                    usdaItem.idValue = itemDictionary[kAPIID] as String //Already tested above to make sure it exists
                    usdaItem.dateAdded = NSDate()
                    if let fieldsDictionary = itemDictionary[kAPIFields] as? NSDictionary {
                        if fieldsDictionary[kAPIItemNameField] != nil {
                            usdaItem.name = fieldsDictionary[kAPIItemNameField] as String
                        }
                        if let usdaFieldsDictionary = fieldsDictionary[kAPIUSDAFields] as? NSDictionary {
                            if let calciumDictionary = usdaFieldsDictionary[kAPICalciumField] as? NSDictionary {
                                let calciumValue: AnyObject = calciumDictionary[kAPIComponentValue]!
                                usdaItem.calcium = "\(calciumValue)"
                            } else {usdaItem.calcium = "0"}
                            
                            if let carbDictionary = usdaFieldsDictionary[kAPICarbohydratesField] as? NSDictionary {
                                let carbValue: AnyObject = carbDictionary[kAPIComponentValue]!
                                usdaItem.carbohydrate = "\(carbValue)"
                            } else {usdaItem.carbohydrate = "0"}
                            
                            if let fatDictionary = usdaFieldsDictionary[kAPIFatTotalField] as? NSDictionary {
                                let fatValue: AnyObject = fatDictionary[kAPIComponentValue]!
                                usdaItem.fatTotal = "\(fatValue)"
                            } else {usdaItem.fatTotal = "0"}
                            
                            if let cholesterolDictionary = usdaFieldsDictionary[kAPICholesterolField] as? NSDictionary {
                                let cholesterolValue: AnyObject = cholesterolDictionary[kAPIComponentValue]!
                                usdaItem.cholesterol = "\(cholesterolValue)"
                            } else {usdaItem.cholesterol = "0"}
                            
                            if let proteinDictionary = usdaFieldsDictionary[kAPIProteinField] as? NSDictionary {
                                let proteinValue: AnyObject = proteinDictionary[kAPIComponentValue]!
                                usdaItem.protein = "\(proteinValue)"
                            } else {usdaItem.protein = "0"}
                            
                            if let sugarDictionary = usdaFieldsDictionary[kAPISugarField] as? NSDictionary {
                                let sugarValue: AnyObject = sugarDictionary[kAPIComponentValue]!
                                usdaItem.sugar = "\(sugarValue)"
                            } else {usdaItem.sugar = "0"}
                            
                            if let vitCDictionary = usdaFieldsDictionary[kAPIVitaminCField] as? NSDictionary {
                                let vitCValue: AnyObject = vitCDictionary[kAPIComponentValue]!
                                usdaItem.vitaminC = "\(vitCValue)"
                            } else {usdaItem.vitaminC = "0"}
                            
                            if let energyDictionary = usdaFieldsDictionary[kAPIEnergyField] as? NSDictionary {
                                let energyValue: AnyObject = energyDictionary[kAPIComponentValue]!
                                usdaItem.energy = "\(energyValue)"
                            } else {usdaItem.energy = "0"}
                            
                            (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
                        }
                    }
                }
            }
        }
    }
}
//
//
//
//
//
//
//
//
//
//
//
//
//
