//
//  Constants.swift
//  Energieq
//
//  Created by Binate on 14/5/18.
//  Copyright © 2018 Shah Yasin. All rights reserved.
//

import UIKit

class Constants: NSObject {
    #if PRODUCTION
        static let BaseApi = "https://app.vindm.nu:8073/api/"
    #else
        static let BaseApi = "https://staging.vindm.nu:8073/api/"
    #endif
    
    #if PRODUCTION
    static let BaseSiteUrl = "https://app.vindm.nu"
    #else
    static let BaseSiteUrl = "https://staging.vindm.nu"
    #endif

    
    static let Users = "users/"
    static let Login = "login/"
    static let Logout = "logout/"
    static let Password_Reset = "password-reset/"
    static let User_Profile = "profile/"
    static let Jobs = "jobs/"
    static let Vacancy = "vacancy/"
    static let Vacancy_Interst = "vacancy-interest/"
    static let Career = "careers/"
    static let TrainingItem = "training-item/"
    static let Category = "job-category/"
    static let UserCategoryItem = "user-category-item/"
    static let Bulk = "bulk/"
    static let Domain = "job-domain/"
    static let CategoryItemValidation = "category-item-validation/"
    static let FieldGroup = "field-group/"

    

    static let Http_Post = "POST"
    static let Http_Get = "GET"
    static let Http_Put = "PUT"
    static let Http_Delete = "DELETE"
    
    static let Email_Key = "email"
    static let Password_Key = "password"
    static let Login_Code_Key = "login_code"
    static let Has_Accepted_terms_Key = "has_accepted_terms"
    static let Login_Type_Key = "login_type"
    static let Social_token_key = "social_token"
    static let Code_key = "code"
    static let Confirm_Password_Key = "confirm_password"

    static let   ResetPassword_VC     = "ResetPasswordVC"
    static let Details_VC = "Details_VC"
    static let      VaccancyDetailsV_C      = "VaccancyDetailsV_C"
    static let      CategoryList_VC      = "CategoryList_VC"
    static let      ProfileOverview_VC      = "ProfileOverview_VC"
    static let Profile_Update_VC = "Update_Profile"
    static let Terms_Conditions_VC = "Terms_ConditionsViewController"
    
    static let  detailsTableViewCell = "VaccancyDetailsTableViewCell"
    static let  detailsCategoryTableViewCell = "VaccancyDetailsCategoryTableViewCell"
    static let  favVacncyTableViewCell = "FavVaccancyTableViewCell"
    static let  demoJobsCollectionViewCell = "DemoJobsCollectionViewCell"


    static let LoggedIn_Key  =  "loggedin"
    static let UserUUID_Key  =  "useruuid"
    static let UserToken_Key  =  "usertoken"
    static let UserProfile_Key  =  "userprofilestatus"
    static let UserFrstTime_Key  =  "userFrstTime"
    static let CategoryData       =  "CategoryData"
    static let AcceptedTerms_Key  =  "acceptedTerms"

    //static let primaryBlueColor = "#092A53"
    static let primaryBlueColor = "#154E94"
    static let secondaryBlueColor = "#0F7DC1"
    static let secondaryColor = "#FF9300"
    
    static let EEEEddMMMM        =  "EEEE dd MMMM yyyy"
     static let dd_MM_yyyyHHmm   =   "dd-MM-yyyy HH:mm"
}
