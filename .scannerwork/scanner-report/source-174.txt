//
//  ActivitiesViewController.swift
//  Snow IO
//
//  Created by Steven F. on 04/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

class ActivitiesViewController: UICollectionViewController, UISearchResultsUpdating, UICollectionViewDelegateFlowLayout, UserInterestsProtocol, pullRefreshProtocol, mainBackScreenProtocol, screenToBackProtocol {

    // Loading Bar View XIB
    var loadingView = LoadingBarView()
    
    // BackScreen Protocol
    typealias previousScreen = ItemActivitiesViewController
    internal typealias `Self` = ActivitiesViewController
    static var isBacked: Bool = false
    
    // Managers
    var mAlertManager = AlertsManager()
    var mDatasourceManager = SnowIOFirebaseManager()
    
    // Datas
    var mInterestsList: Array<InterestModel>!
    var mFilteredInterestList : Array<InterestModel>!
    
    // Selected value
    var selectedCategorie: String!
    var selectedItem: InterestModel!
    
    
    // MARK : APP Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if(Self.isBacked) {
            Self.isBacked = false
        }
        
        self.navigationItem.title = NSLocalizedString("category_title", comment: "") + self.selectedCategorie.firstUppercased
        mDatasourceManager.userInterestProtocol = self
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if(previousScreen.isBacked == true) {
            previousScreen.isBacked = false
            mDatasourceManager.userInterestProtocol = self
            setupView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if(DrawerViewController.isOpen == false) {
            resetView(isExit: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(self.isMovingFromParentViewController) {
            Self.isBacked = true
        }
    }
    
    // MARK : IBACTIONS
    @IBAction func moreBtn(_ sender: Any) {
        mAlertManager.showAboutActions()
    }
    
    // MARK : Custom Method
    func setupView() {
        // Setup Table & embedded views
        setupTable()
        setupPullRefresh()
        adjustLoadingFromZero(loading: loadingView)
        showLoading(view: self.view, loading: loadingView)
        
        // Search Controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        // Search Controller Appareance
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: NSLocalizedString("search_interests", comment: ""), attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        mDatasourceManager.getCategoriesInteresetList(categorieChoose: self.selectedCategorie)
    }
    
    func resetView(isExit: Bool) {
        
        if(mInterestsList != nil) {
            mInterestsList = nil
        }
        
        if(isExit) {
            navigationItem.searchController = nil
        }
        
        removeEmptyMessage()
        emptyTableApplyData()
    }
    
    // MARK : Crystal-IOT DataSource Methods
    func performAction(interestsList: Array<InterestModel>) {
        mInterestsList = interestsList
        
        if(mInterestsList?.isEmpty == true) {
            emptyTableApplyData()
            showEmptyMessage(localizedKeyString: "empty_list")
        } else {
            hasValueTableApplyData()
        }
        
        removeLoadingView(loadingView: loadingView)
        endRefresh()
    }
    
    func cancelAction() {
        emptyTableApplyData()
        removeLoadingView(loadingView: loadingView)
        showEmptyMessage(localizedKeyString: "api_error_server")
        endRefresh()
    }
    
    // MARK : Pull To Refresh DataSource Methods
    func reloadData() {
        showLoading(view: self.view, loading: loadingView)
        resetView(isExit: false)
        mDatasourceManager.getCategoriesInteresetList(categorieChoose: self.selectedCategorie)
    }
    
    // MARK : SearchBar Controlelr Delegate Methods
    func updateSearchResults(for searchController: UISearchController) {
        if(mInterestsList != nil) {
            filterContentForSearchText (searchController.searchBar.text!)
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return self.navigationItem.searchController?.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        mFilteredInterestList = mInterestsList.filter({( categorie : InterestModel) -> Bool in
            let doesCategoryMatch = (scope == "All") || (categorie.name == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return categorie.name.lowercased().contains(searchText.lowercased())
            }
        })
        
        self.collectionView?.reloadData()
    }
    
    func isFiltering() -> Bool {
        return self.navigationItem.searchController?.isActive != nil ? (self.navigationItem.searchController?.isActive)! : false && !searchBarIsEmpty()
    }
    
    // MARK: - CollectionView data source
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering() {
            return mFilteredInterestList.count
        } else {
            if(mInterestsList != nil) {
                return mInterestsList.count
            } else {
                return 0
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCollectionInterests", for: indexPath) as? itemCollectionInterests
        
        if isFiltering() {
            if(mFilteredInterestList[indexPath.row].image != "nil") {
                cell?.imageInterest.image = PictureManager().decodeStringToImage(image: mFilteredInterestList[indexPath.row].image)
            }
            cell?.nameInterest.text = mFilteredInterestList[indexPath.row].name
        }
        else {
            if(mInterestsList[indexPath.row].image != "nil") {
                cell?.imageInterest.image = PictureManager().decodeStringToImage(image: mInterestsList[indexPath.row].image)
            }
            cell?.nameInterest.text = mInterestsList[indexPath.row].name
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 250)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isFiltering() {
            self.selectedItem = mFilteredInterestList[indexPath.row]
        } else {
            self.selectedItem = mInterestsList[indexPath.row]
        }
        performSegue(withIdentifier: "selectedItemSegue", sender: self)
    }
    
    // MARK : Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectedItemSegue" {
            let itemScreen = segue.destination as? ItemActivitiesViewController
            itemScreen?.selectedItem = self.selectedItem
        }
    }
    
}
