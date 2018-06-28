//
//  ActivitiesViewController.swift
//  Snow IO
//
//  Created by Steven F. on 26/03/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

class CategoriesActivitiesViewController: UICollectionViewController, UISearchResultsUpdating, UICollectionViewDelegateFlowLayout, UserCategorieInterestsProtocol, pullRefreshProtocol, mainBackScreenProtocol {
    
    // Loading Bar View XIB
    var loadingView = LoadingBarView()
    
    // BackScreen Protocol
    typealias previousScreen = ActivitiesViewController
    
    // Managers
    var mAlertManager = AlertsManager()
    var mDatasourceManager = SnowIOFirebaseManager()
    
    // Datas
    var mCatInterestList: Array<InterestCategorie>!
    var mFilteredInterestList : Array<InterestCategorie>!
    
    // Selected value
    var selectedCategorie: String!
    
    
    // MARK : APP Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mDatasourceManager.userCategorieInterestProtocol = self
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if(previousScreen.isBacked == true) {
            previousScreen.isBacked = false
            mDatasourceManager.userCategorieInterestProtocol = self
            setupView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if(DrawerViewController.isOpen == false) {
            resetView(isExit: true)
        }
    }
    
    // MARK : IBACTIONS
    @IBAction func menuBtn(_ sender: Any) {
        if let drawerController = navigationController?.parent as? DrawerViewController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
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
                
        mDatasourceManager.getCategoriesInteresetList()
    }
    
    func resetView(isExit: Bool) {
        
        if(mCatInterestList != nil) {
            mCatInterestList = nil
        }
        
        if(isExit) {
            navigationItem.searchController = nil
        }
        
        removeEmptyMessage()
        emptyTableApplyData()
    }
    
    // MARK : Crystal-IOT DataSource Methods
    func performAction(categorieInterestsList: Array<InterestCategorie>) {
        mCatInterestList = categorieInterestsList
        
        if(mCatInterestList?.isEmpty == true) {
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
        mDatasourceManager.getCategoriesInteresetList()
    }
    
    // MARK : SearchBar Controlelr Delegate Methods
    func updateSearchResults(for searchController: UISearchController) {
        if(mCatInterestList != nil) {
            filterContentForSearchText (searchController.searchBar.text!)
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return self.navigationItem.searchController?.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        mFilteredInterestList = mCatInterestList.filter({( categorie : InterestCategorie) -> Bool in
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
            if(mCatInterestList != nil) {
                return mCatInterestList.count
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
        } else {
            if(mCatInterestList[indexPath.row].image != "nil") {
                cell?.imageInterest.image = PictureManager().decodeStringToImage(image: mCatInterestList[indexPath.row].image)
            }
            
            cell?.nameInterest.text = mCatInterestList[indexPath.row].name
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 210)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isFiltering() {
            self.selectedCategorie = mFilteredInterestList[indexPath.row].name
        } else {
            self.selectedCategorie = mCatInterestList[indexPath.row].name
        }
        performSegue(withIdentifier: "selectedCategorieSegue", sender: self)
    }
    
    // MARK : Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectedCategorieSegue" {
            let activitiesScreen = segue.destination as? ActivitiesViewController
            activitiesScreen?.selectedCategorie = self.selectedCategorie
        }
    }
    
}

class itemCollectionInterests: UICollectionViewCell {
    @IBOutlet weak var imageInterest: UIImageView!
    @IBOutlet weak var nameInterest: UILabel!
    
    override func awakeFromNib() {
        nameInterest.numberOfLines = 0
        nameInterest.lineBreakMode = .byWordWrapping
        nameInterest.sizeToFit()
    }
}

