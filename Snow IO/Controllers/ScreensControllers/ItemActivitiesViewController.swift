//
//  ItemActivitiesViewController.swift
//  Snow IO
//
//  Created by Steven F. on 04/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import UIKit

class ItemActivitiesViewController: UITableViewController, screenToBackProtocol {
    
    // Loading Bar View XIB
    var loadingView = LoadingBarView()
    
    // Managers
    var mAlertManager = AlertsManager()
    var mDateManager = DateTimeManager()
    var mDatasourceManager = SnowIOFirebaseManager()
    
    // BackScreen Protocol
    internal typealias `Self` = ItemActivitiesViewController
    static var isBacked: Bool = false
    
    // Selected value
    var selectedItem: InterestModel?
    var hoursArray = Array<ScheduleHours>()
    
    // Segue Variables
    var activityPosition: PositionModel?
    let mapIdentifier = "mapSegue"

    
    // MARK : APP Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Self.isBacked) {
            Self.isBacked = false
        }
        
        self.navigationItem.title = NSLocalizedString("activity_title", comment: "") + (self.selectedItem?.name.firstUppercased)!
        setupView()
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

        hoursArray.append((selectedItem?.hours.monday)!)
        hoursArray.append((selectedItem?.hours.tuesday)!)
        hoursArray.append((selectedItem?.hours.wednesday)!)
        hoursArray.append((selectedItem?.hours.thursday)!)
        hoursArray.append((selectedItem?.hours.friday)!)
        hoursArray.append((selectedItem?.hours.saturday)!)
        hoursArray.append((selectedItem?.hours.sunday)!)
        
        hasValueTableApplyData()
    }
    
    func resetView() {
        selectedItem = nil
        
        removeEmptyMessage()
        emptyTableApplyData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "activityInformations", for: indexPath) as? activityInformations
            
            cell?.activityName.text = selectedItem?.name.firstUppercased
            cell?.activityDescription.text = selectedItem?.longDescription.firstUppercased
            
            cell?.hoursInformations.text = NSLocalizedString("interest_hours", comment: "")
        
            var hoursDescription = ""
            var hoursIndex = 0
            for elem in self.hoursArray {
                let formattedDay = mDatasourceManager.getFormattedInterestsDate(index: hoursIndex)
                let formattedDate = mDateManager.getFormattedDate(numberInHours: elem.beginHour) + " - " +
                                    mDateManager.getFormattedDate(numberInHours: elem.endHour)
                
                hoursDescription += formattedDay + formattedDate + "\n\n"
        
                hoursIndex = hoursIndex+1
            }
            cell?.hoursDescription.text = hoursDescription
            
            if(selectedItem?.image != "nil") {
                cell?.activityImage.image = PictureManager().decodeStringToImage(image: (selectedItem?.image)!)
            }
            
            return cell!
        }
        else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "activityPosition", for: indexPath) as? activityPosition
            cell?.positionName.text = NSLocalizedString("interest_access", comment: "")
            
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "activityValueDetection", for: indexPath) as? activityValueDetection
            cell?.informationName.text = NSLocalizedString("account_tel", comment: "")
            
            cell?.informationValue.textContainer.maximumNumberOfLines = 1
            cell?.informationValue.textContainer.lineBreakMode = .byTruncatingTail
            cell?.informationValue?.alignTextVerticallyInContainer()
            
            cell?.informationValue.text = selectedItem?.phone
           
            return cell!
        }
        return UITableViewCell()
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0) {
            return UITableViewAutomaticDimension
        } else {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 1) {
            self.activityPosition = selectedItem?.position
            self.performSegue(withIdentifier: self.mapIdentifier, sender: self)
        }
    }
    
    // MARK : - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc: DrawerViewController = segue.destination as? DrawerViewController {
            if segue.identifier == mapIdentifier {
                AppDelegate.currentPage = IndexPath(row: 3, section: 1)
                vc.actionToPerform = mapIdentifier
                vc.mapData = activityPosition
            }
        }
    }

}


class activityInformations: UITableViewCell {
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var activityImage: UIImageView!
    @IBOutlet weak var activityDescription: UILabel!
    @IBOutlet weak var hoursInformations: UILabel!
    @IBOutlet weak var hoursDescription: UILabel!
    
    override func awakeFromNib() {
        activityDescription.numberOfLines = 0
        activityDescription.lineBreakMode = .byWordWrapping
        activityDescription.sizeToFit()
        
        hoursDescription.numberOfLines = 0
        activityDescription.lineBreakMode = .byWordWrapping
        activityDescription.sizeToFit()
    }
}

class activityPosition: UITableViewCell {
    @IBOutlet weak var positionName: UILabel!
    @IBOutlet weak var positionButton: UIButton!
}

class activityValueDetection: UITableViewCell {
    @IBOutlet weak var informationName: UILabel!
    @IBOutlet weak var informationValue: UITextView!
}

