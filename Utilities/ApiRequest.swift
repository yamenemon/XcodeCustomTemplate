//
//  ApiRequest.swift
//  Energieq
//
//  Created by Binate on 14/5/18.
//  Copyright © 2018 Shah Yasin. All rights reserved.
//

import UIKit
import Reachability
import ObjectMapper

@objc protocol ApiRequestDelegate {
    func connectivityError( )
}



class ApiRequest: NSObject {
    
    weak var delegate: ApiRequestDelegate?

    var dataDictionary = NSDictionary()
    
    enum HTTPResult {
        case HTTP_OK
        case HTTP_CONTENT_NOT_FOUND
        case HTTP_BAD_REQUEST
        case HTTP_UNAUTHORIZE
        case HTTP_SERVER_ERROR
        case HTTP_NG
        case HTTP_BAD_GATEWAY


    }
    
    //MARK: - RequestBodyMaker

    func createApiBodyKeys(_ keys: [Any]?, andValues values: [Any]?) {
        dataDictionary = NSDictionary.init(objects: values!, forKeys: keys as! [NSCopying])
    }
    
    //MARK: - RequestMaker

    
    func performApiRequest(_ url: URL?, forMethod httpMethod: String?, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        let defaultConfiguration = URLSessionConfiguration.default
        let urlSession = URLSession.init(configuration: defaultConfiguration)
        var urlRequest = URLRequest.init(url:url!)
        urlRequest.httpMethod = httpMethod!
        urlRequest.httpShouldHandleCookies = false
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = Utility.getUserToken();
        if (token != "") {
            urlRequest.setValue(String.init(format: "JWT %@", token), forHTTPHeaderField: "Authorization")
        }
        
        if dataDictionary.allKeys.count > 0 {
            let dataFromDict: Data? = try? JSONSerialization.data(withJSONObject: dataDictionary, options: .prettyPrinted)
                urlRequest.httpBody = dataFromDict
        }
        
        
        let dataTask: URLSessionDataTask? = urlSession.dataTask(with: urlRequest, completionHandler: {(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            self.dataDictionary = NSDictionary.init()
            completionHandler(data, response, error)
        })
        dataTask?.resume()
    }
    
    //MARK: - HttpResultFromStatusCode
    
    func httpResultFromStatusCode(responsStatus : NSInteger) -> HTTPResult {
        
       var result = HTTPResult.HTTP_OK
        
        switch (responsStatus) {
        case 200:
            result = HTTPResult.HTTP_OK;
            break;
        case 201:
            result = HTTPResult.HTTP_OK;
            break;
        case 400:
            result = HTTPResult.HTTP_BAD_REQUEST;
            break;
        case 403:
            result = HTTPResult.HTTP_UNAUTHORIZE;
            break;
        case 404:
            result = HTTPResult.HTTP_CONTENT_NOT_FOUND;
            break;
        case 500:
            result = HTTPResult.HTTP_SERVER_ERROR;
            break;
        case 503:
            result = HTTPResult.HTTP_BAD_GATEWAY;
            break;
        default:
            result = HTTPResult.HTTP_NG;
            break;
        }
        return result;

    }
    
    
    //MARK: - Requests

    
    
    func performLogout(_ userUUID: String?, success successBlock: @escaping () -> Void, failure failureBlock: @escaping (_ dict: NSDictionary?) -> Void, serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping () -> Void,accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void) {
        
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        let url = NSURL.init(string: String.init(format: "%@%@%@", Constants.BaseApi,Constants.Users,Constants.Logout))
        performApiRequest(url as URL?, forMethod: Constants.Http_Post, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                //print("fetchUserCompanyInfo", responseDictionary as Any );
                if result == HTTPResult.HTTP_OK{
                    successBlock()
                }else if (result == HTTPResult.HTTP_BAD_REQUEST || result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    failureBlock(responseDictionary);
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                    accestokenInvalid();
                }
                else{
                    serverError(responseDictionary );
                }
            }
        })

    }
    

    
    func performLogin(_ userUUID: String?, success successBlock: @escaping (_ user : UserModel) -> Void, failure failureBlock: @escaping (_ dict: NSDictionary?) -> Void, serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void) {
        
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        
        let url = NSURL.init(string: String.init(format: "%@%@%@", Constants.BaseApi,Constants.Users,Constants.Login))
        performApiRequest(url as URL?, forMethod: Constants.Http_Post, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                //print("fetchUserCompanyInfo", responseDictionary as Any );
                if result == HTTPResult.HTTP_OK{
                    let responseData = try? JSONSerialization.data(withJSONObject: responseDictionary!["results"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let convertedString = String(data: responseData! , encoding: String.Encoding.utf8)
                    let user = UserModel(JSONString:convertedString!)
                    successBlock(user!)
                }else if (result == HTTPResult.HTTP_BAD_REQUEST || result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    failureBlock(responseDictionary);
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }else{
                    serverError(responseDictionary );
                }
            }
        })
        
    }
    
    
    
    func performResetPassword(success successBlock: @escaping () -> Void, failure failureBlock: @escaping (_ dict: NSDictionary?) -> Void, serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping () -> Void,operationError: @escaping (_ error: Error?) -> Void) {
        
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }

        let url = NSURL.init(string: String.init(format: "%@%@%@%@/", Constants.BaseApi,Constants.Users,Constants.Password_Reset,Constants.Email_Key))
        performApiRequest(url as URL?, forMethod: Constants.Http_Post, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                //print("fetchUserCompanyInfo", responseDictionary as Any );
                if result == HTTPResult.HTTP_OK{
                    successBlock()
                }else if (result == HTTPResult.HTTP_BAD_REQUEST || result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    failureBlock(responseDictionary);
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                } else{
                    serverError(responseDictionary );
                }
            }
        })
        
    }
    
    func changePassword(success successBlock: @escaping () -> Void, failure failureBlock: @escaping (_ dict: NSDictionary?) -> Void, serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void) {
       
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }

        let url = NSURL.init(string: String.init(format: "%@%@%@", Constants.BaseApi,Constants.Users,Constants.Password_Reset))
        performApiRequest(url as URL?, forMethod: Constants.Http_Post, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                //print("fetchUserCompanyInfo", responseDictionary as Any );
                if result == HTTPResult.HTTP_OK{
                    successBlock()
                }else if (result == HTTPResult.HTTP_BAD_REQUEST || result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    failureBlock(responseDictionary);
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }
                else{
                    serverError(responseDictionary );
                }
            }
        })
        
    }
    
    func getUserInfo(success successBlock: @escaping (_ user: UserModel) -> Void, failure failureBlock: @escaping (_ dict: NSDictionary) -> Void, serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping () -> Void, accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void){
        
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }

        let url = NSURL(string: String(format: "%@%@%@%@/", Constants.BaseApi,Constants.Users,Constants.User_Profile,Utility.getUserUUID()))
        
        performApiRequest(url as URL?, forMethod: Constants.Http_Get, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                if result == HTTPResult.HTTP_OK{
                    let responseData = try? JSONSerialization.data(withJSONObject: responseDictionary!["results"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let convertedString = String(data: responseData! , encoding: String.Encoding.utf8)
                    let user = UserModel(JSONString:convertedString!)
                    DataManager.sharedInstance.userObject = user
                    successBlock(user!)
                }else if (result == HTTPResult.HTTP_BAD_REQUEST || result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    failureBlock(responseDictionary!);
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                    accestokenInvalid();
                }
                else{
                    serverError(responseDictionary );
                }
            }
        })
    }
    
    
    func getVacancyList(_ isFavourite :Bool,success successBlock: @escaping (_ vacancy: [VacancyModel]) -> Void, failure failureBlock: @escaping (_ dict: NSDictionary) -> Void,contentnotFound:  @escaping () -> Void,serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping () -> Void, accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void){
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        
        var url = NSURL(string: String(format: "%@%@%@", Constants.BaseApi,Constants.Jobs,Constants.Vacancy))
        if isFavourite {
            url = NSURL(string: String(format: "%@%@%@?custom_filter__is_interested=True", Constants.BaseApi,Constants.Jobs,Constants.Vacancy))
        }
        performApiRequest(url as URL?, forMethod: Constants.Http_Get, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                //print("fetchUserCompanyInfo", responseDictionary as Any );
                if result == HTTPResult.HTTP_OK{
                    let responseData = try? JSONSerialization.data(withJSONObject: responseDictionary!["results"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let convertedString = String(data: responseData! , encoding: String.Encoding.utf8)
                    let vacancies = Mapper<VacancyModel>().mapArray(JSONString: convertedString!)
                    successBlock(vacancies!)
                }else if (result == HTTPResult.HTTP_BAD_REQUEST ){
                    failureBlock(responseDictionary!);
                }else if(result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    contentnotFound();
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                    accestokenInvalid();
                }
                else{
                    serverError(responseDictionary );
                }
            }
        })
    }
    
    
    func vacancyInterestAPI(success successBlock: @escaping (_ vacancy : VacancyModel) -> Void, failure failureBlock: @escaping (_ dict: NSDictionary) -> Void,contentnotFound:  @escaping () -> Void,serverError: @escaping (_ dict :NSDictionary ) -> Void, operationFailed: @escaping () -> Void, accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void){
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        
        let url = NSURL(string: String(format: "%@%@%@", Constants.BaseApi,Constants.Jobs,Constants.Vacancy_Interst))
        
        performApiRequest(url as URL?, forMethod: Constants.Http_Post, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                //print("fetchUserCompanyInfo", responseDictionary as Any );
                if result == HTTPResult.HTTP_OK{
                    let responseData = try? JSONSerialization.data(withJSONObject: responseDictionary!["results"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let convertedString = String(data: responseData! , encoding: String.Encoding.utf8)
                    let vacancy = VacancyModel(JSONString:convertedString!)
                    successBlock(vacancy!)
                }else if (result == HTTPResult.HTTP_BAD_REQUEST ){
                    failureBlock(responseDictionary!);
                }else if(result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    contentnotFound();
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                    accestokenInvalid();
                }
                else{
                    serverError(responseDictionary! );
                }
            }
        })
    }
    
    
    func deleteVacancyInterestAPI(_ vacancyUUid : String,success successBlock: @escaping () -> Void, failure failureBlock: @escaping (_ dict: NSDictionary) -> Void,contentnotFound:  @escaping () -> Void,serverError: @escaping (_ dict :NSDictionary ) -> Void, operationFailed: @escaping () -> Void, accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void){
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        
        let url = NSURL(string: String(format: "%@%@%@%@/", Constants.BaseApi,Constants.Jobs,Constants.Vacancy_Interst,vacancyUUid))
        
        performApiRequest(url as URL?, forMethod: Constants.Http_Delete, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                print("deleteVacancyInterestAPI", responseDictionary as Any );
                if result == HTTPResult.HTTP_OK{
                    successBlock()
                }else if (result == HTTPResult.HTTP_BAD_REQUEST ){
                    failureBlock(responseDictionary!);
                }else if(result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    contentnotFound();
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                    accestokenInvalid();
                }
                else{
                    serverError(responseDictionary! );
                }
            }
        })
    }


    func getTrainingData(filter: String,success successBlock: @escaping (_ trainingData: [TrainingModel]) -> Void, failure failureBlock: @escaping (_ dict: NSDictionary) -> Void, serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping () -> Void, accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void){
        
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        
        let url = NSURL(string: String(format: "%@%@%@?%@", Constants.BaseApi,Constants.Career,Constants.TrainingItem,filter))
        
        performApiRequest(url as URL?, forMethod: Constants.Http_Get, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                if result == HTTPResult.HTTP_OK{
                    let responseData = try? JSONSerialization.data(withJSONObject: responseDictionary!["results"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let convertedString = String(data: responseData! , encoding: String.Encoding.utf8)
                    let trainingData = Mapper<TrainingModel>().mapArray(JSONString: convertedString!)
                    successBlock(trainingData!)
                }else if (result == HTTPResult.HTTP_BAD_REQUEST || result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    failureBlock(responseDictionary!);
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                    accestokenInvalid();
                }
                else{
                    serverError(responseDictionary );
                }
            }
        })
    }
    
    func getCategoryData(successBlock: @escaping (_ categoryData: [CategoryModel]) -> Void, failure failureBlock: @escaping (_ dict: NSDictionary) -> Void, serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping () -> Void, accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void){
        
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        
        let url = NSURL(string: String(format: "%@%@%@", Constants.BaseApi,Constants.Jobs,Constants.Category))
        
        performApiRequest(url as URL?, forMethod: Constants.Http_Get, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                if result == HTTPResult.HTTP_OK{
                    let responseData = try? JSONSerialization.data(withJSONObject: responseDictionary!["results"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let convertedString = String(data: responseData! , encoding: String.Encoding.utf8)
                    let trainingData = Mapper<CategoryModel>().mapArray(JSONString: convertedString!)
                    successBlock(trainingData!)
                }else if (result == HTTPResult.HTTP_BAD_REQUEST || result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    failureBlock(responseDictionary!);
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                    accestokenInvalid();
                }
                else{
                    serverError(responseDictionary );
                }
            }
        })
    }
    
    func performProfileUpdate(success successBlock: @escaping () -> Void, failure failureBlock: @escaping (_ dict: NSDictionary) -> Void, serverError: @escaping (_ dict: NSDictionary) -> Void, operationFailed: @escaping () -> Void,accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void) {
        
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        let url = NSURL.init(string: String.init(format: "%@%@%@%@", Constants.BaseApi,Constants.Jobs,Constants.UserCategoryItem,Constants.Bulk))
        performApiRequest(url as URL?, forMethod: Constants.Http_Post, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                if result == HTTPResult.HTTP_OK{
                    successBlock()
                }else if (result == HTTPResult.HTTP_BAD_REQUEST || result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    failureBlock(responseDictionary!);
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                    accestokenInvalid();
                }
                else{
                    serverError(responseDictionary! );
                }
            }
        })
        
    }
    func updateUserInfo( success successBlock: @escaping (_ user: UserModel) -> Void, failure failureBlock: @escaping (_ dict: NSDictionary?) -> Void, serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping (_ dict: NSDictionary?) -> Void,accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void) {
        
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        let url = NSURL.init(string: String.init(format: "%@%@%@%@/", Constants.BaseApi,Constants.Users,Constants.User_Profile,Utility.getUserUUID()))
        performApiRequest(url as URL?, forMethod: Constants.Http_Put, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                if result == HTTPResult.HTTP_OK{
                    let responseData = try? JSONSerialization.data(withJSONObject: responseDictionary!["results"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let convertedString = String(data: responseData! , encoding: String.Encoding.utf8)
                    let user = UserModel(JSONString:convertedString!)
                    DataManager.sharedInstance.userObject = user
                    successBlock(user!)
                }else if (result == HTTPResult.HTTP_BAD_REQUEST || result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    failureBlock(responseDictionary!);
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed(responseDictionary);
                }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                    accestokenInvalid();
                } else{
                    serverError(responseDictionary! );
                }
            }
        })
        
    }
    
    func getDomainList(success successBlock: @escaping (_ domainList: [JobDomainModel]) -> Void, failure failureBlock: @escaping (_ dict: NSDictionary) -> Void,contentnotFound:  @escaping () -> Void,serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping () -> Void, accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void){
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        
        let url = NSURL(string: String(format: "%@%@%@", Constants.BaseApi,Constants.Jobs,Constants.Domain))
        
        performApiRequest(url as URL?, forMethod: Constants.Http_Get, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                //print("fetchUserCompanyInfo", responseDictionary as Any );
                if result == HTTPResult.HTTP_OK{
                    let responseData = try? JSONSerialization.data(withJSONObject: responseDictionary!["results"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let convertedString = String(data: responseData! , encoding: String.Encoding.utf8)
                    let vacancies = Mapper<JobDomainModel>().mapArray(JSONString: convertedString!)
                    successBlock(vacancies!)
                }else if (result == HTTPResult.HTTP_BAD_REQUEST ){
                    failureBlock(responseDictionary!);
                }else if(result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    contentnotFound();
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                    accestokenInvalid();
                }
                else{
                    serverError(responseDictionary );
                }
            }
        })
    }
    
    func getValidationList(success successBlock: @escaping (_ validationList: [CategoryValidationModel]) -> Void, failure failureBlock: @escaping (_ dict: NSDictionary) -> Void,contentnotFound:  @escaping () -> Void,serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping () -> Void, accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void){
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        let dataCount = DataManager.sharedInstance.validationList?.count as! Int
        if(dataCount > 0){
            successBlock(DataManager.sharedInstance.validationList!)
            return
        }
        let url = NSURL(string: String(format: "%@%@%@?type=0", Constants.BaseApi,Constants.Jobs,Constants.CategoryItemValidation))
        
        performApiRequest(url as URL?, forMethod: Constants.Http_Get, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                print("fetchValidationInfo", responseDictionary as Any );
                if result == HTTPResult.HTTP_OK{
                    let responseData = try? JSONSerialization.data(withJSONObject: responseDictionary!["results"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let convertedString = String(data: responseData! , encoding: String.Encoding.utf8)
                    let validation = Mapper<CategoryValidationModel>().mapArray(JSONString: convertedString!)
                    DataManager.sharedInstance.validationList = validation
                    successBlock(validation!)
                }else if (result == HTTPResult.HTTP_BAD_REQUEST ){
                    failureBlock(responseDictionary!);
                }else if(result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    contentnotFound();
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                    accestokenInvalid();
                }
                else{
                    serverError(responseDictionary );
                }
            }
        })
    }
    
    func getValidationForCategory(uuid : String ,success successBlock: @escaping (_ validation: CategoryValidationModel) -> Void, failure failureBlock: @escaping (_ dict: NSDictionary) -> Void,contentnotFound:  @escaping () -> Void,serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping () -> Void, accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void){
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        
        let url = NSURL(string: String(format: "%@%@%@%@/?type=0", Constants.BaseApi,Constants.Jobs,Constants.CategoryItemValidation,uuid))
        
        performApiRequest(url as URL?, forMethod: Constants.Http_Get, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                print("fetchValidationInfo", responseDictionary as Any );
                if result == HTTPResult.HTTP_OK{
                    let responseData = try? JSONSerialization.data(withJSONObject: responseDictionary!["results"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let convertedString = String(data: responseData! , encoding: String.Encoding.utf8)
                    let validation = Mapper<CategoryValidationModel>().map(JSONString: convertedString!)
                    successBlock(validation!)
                }else if (result == HTTPResult.HTTP_BAD_REQUEST ){
                    failureBlock(responseDictionary!);
                }else if(result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    contentnotFound();
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                    accestokenInvalid();
                }
                else{
                    serverError(responseDictionary );
                }
            }
        })
    }
 
    func getVacancyFieldGroupList(success successBlock: @escaping (_ dict: NSDictionary) -> Void, failure failureBlock: @escaping (_ dict: NSDictionary) -> Void,contentnotFound:  @escaping () -> Void,serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping () -> Void, accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void){
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        
        let url = NSURL(string: String(format: "%@%@%@%@", Constants.BaseApi,Constants.Jobs,Constants.Vacancy,Constants.FieldGroup))
        
        performApiRequest(url as URL?, forMethod: Constants.Http_Get, completionHandler:{(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            if error == nil
            {
                let httpResponse = response as? HTTPURLResponse
                let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                print("fetchValidationInfo", responseDictionary as Any );
                if result == HTTPResult.HTTP_OK{
                    successBlock(responseDictionary!)
                }else if (result == HTTPResult.HTTP_BAD_REQUEST ){
                    failureBlock(responseDictionary!);
                }else if(result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                    contentnotFound();
                }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                    operationFailed();
                }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                    accestokenInvalid();
                }
                else{
                    serverError(responseDictionary );
                }
            }
        })
    }
    
    // MARK: - Photo upload method
    func getBoundary() -> String{
        return "Boundary----\(UUID().uuidString)"
    }
    func photoUploadRequest(myUrl: URL,imageData: Data,uploadText: String,success successBlock: @escaping (_ dict: NSDictionary) -> Void, failure failureBlock: @escaping (_ dict: NSDictionary) -> Void,contentnotFound:  @escaping () -> Void,serverError: @escaping (_ dict: NSDictionary?) -> Void, operationFailed: @escaping () -> Void, accestokenInvalid : @escaping () -> Void, operationError: @escaping (_ error: Error?) -> Void){
        
        if !checkIntenetConnection() {
            self.delegate?.connectivityError()
            return
        }
        
        let request = NSMutableURLRequest(url:myUrl as URL);
        request.httpMethod = "PUT";
        
        // Body
        let boundary = getBoundary()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //Image
        var formBody = Data()
        formBody.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        formBody.append("Content-Disposition: form-data; name=\"profile_image\"; filename=\"image.jpg\"\r\n".data(using: String.Encoding.utf8)!)
        formBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8)!)
        formBody.append(imageData)
        formBody.append("\r\n".data(using: String.Encoding.utf8)!)
        formBody.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        
        //User Text
        let upstr = NSString.init(format: "%@\r\n", uploadText) as String
        formBody.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        formBody.append("Content-Disposition: form-data; name=description\r\n\r\n".data(using: String.Encoding.utf8)!)
        formBody.append((upstr.data(using: String.Encoding.utf8)!))
        
        let token = Utility.getUserToken();
        if (token != "") {
            request.setValue(String.init(format: "JWT %@", token), forHTTPHeaderField: "Authorization")
        }
        request.setValue(String(formBody.count), forHTTPHeaderField: "Content-Length")
        request.httpBody = formBody
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
//        Utility.showProgressView(view: self.view)
        let defaultSession = URLSession(configuration: .default)
        
        let task = defaultSession.dataTask(with: request as URLRequest) {
            data, response, error in
            
                if error == nil
                {
                    let httpResponse = response as? HTTPURLResponse
                    let result = self.httpResultFromStatusCode(responsStatus: (httpResponse?.statusCode)!)
                    let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: [])  as! NSDictionary
                    if result == HTTPResult.HTTP_OK{
                        successBlock(responseDictionary!)
                    }else if (result == HTTPResult.HTTP_BAD_REQUEST ){
                        failureBlock(responseDictionary!);
                    }else if(result == HTTPResult.HTTP_CONTENT_NOT_FOUND){
                        contentnotFound();
                    }else if(result ==  HTTPResult.HTTP_BAD_GATEWAY) {
                        operationFailed();
                    }else if (result ==  HTTPResult.HTTP_UNAUTHORIZE){
                        accestokenInvalid();
                    }
                    else{
                        serverError(responseDictionary );
                    }
                    
                }else{
                    accestokenInvalid();
                }
            }
        task.resume()
    }
    
    fileprivate func checkIntenetConnection() -> Bool {
        var isConnected = Bool()
        
        let reachability = Reachability()!
        switch reachability.connection {
        case .wifi:
            isConnected = true
        case .cellular:
            isConnected = true
        case .none:
            isConnected = false
        }
        return isConnected
    }


    

    
}
