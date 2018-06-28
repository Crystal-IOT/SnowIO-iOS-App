//
//  SnowIOFirebaseProtocol.swift
//  Snow IO
//
//  Created by Steven F. on 03/05/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

protocol BeaconManagerProtocol {
    func performBeaconAction(beaconList: Array<BeaconModel>)
    func performSkiSlopeAction(skiSlope : SkiSlopeModel)
    func performSkiStationAction(skiStation: StationModel)
    func cancelAction()
}

protocol UserHomeProtocol {
    func performStationIDAction(stationID: String)
    func performStationSkiSlopeAction(skiSlope: Array<SkiSlopeModel>)
    func performStationSkiSlopeLevelAction(skiSlopeLevelList: Array<SkiSlopeLevel>)
    func performStationSkiSlopeIDAction(skiSlopeID: String)
    func performBeaconListAction(beaconList: Array<BeaconModel>)
}

protocol UserAuthenticationProtocol {
    func performBasicAction()
    func cancelBasicAction()
}

protocol UserProfilAuthenticationProtocol {
    func performAction(profileList: Array<ProfileModel>)
    func cancelAction()
}

protocol UserProfileProtocol {
    func performAction(userAccount: UserModel, userProfile: ProfileModel)
    func performUpdateAction()
    func cancelAction()
}

protocol UserFriendsProtocol {
    func performAction(friendsList : Array<UserModel>)
    func cancelAction()
}

protocol UserStationProtocol {
    func performAction(stationList : Array<StationModel>)
    func cancelAction()
}

protocol UserCategorieInterestsProtocol {
    func performAction(categorieInterestsList : Array<InterestCategorie>)
    func cancelAction()
}

protocol UserInterestsProtocol {
    func performAction(interestsList : Array<InterestModel>)
    func cancelAction()
}
