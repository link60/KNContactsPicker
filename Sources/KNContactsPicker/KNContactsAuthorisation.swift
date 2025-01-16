//
//  KNContactsAuthorisation.swift
//  KNContactsPicker
//
//  Created by Dragos-Robert Neagu on 22/10/2019.
//  Copyright © 2019 Dragos-Robert Neagu. All rights reserved.
//

#if canImport(UIKit) && canImport(Contacts)
import UIKit
import Contacts

public enum KNContactFetchingError: Error {
    // When access was already requested but denied
    case insufficientAccess
    
    // When user was just asked for access but they denied
    case accessNotGranted
    
    // The authorisation status is unknown
    case unknownAuthorisation
    
    // Waiting for user actions
    case pendingAuthorisation
    
    // The fetching
    case fetchRequestFailed
    
    //
    case userCancelled
}

class KNContactsAuthorisation {
    static let contactStore = CNContactStore()
    
    static func requestAccess(conditionToEnableContact: @escaping KNFilteringPredicate, completion: @escaping ((Result<[CNContact], KNContactFetchingError>) -> Void)) {
        
        var result: Result<[CNContact], KNContactFetchingError> = Result.failure(.pendingAuthorisation)
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
                
            case CNAuthorizationStatus.denied, CNAuthorizationStatus.restricted:
                return completion(.failure(.insufficientAccess))
                
            case CNAuthorizationStatus.notDetermined:
                contactStore.requestAccess(for: .contacts, completionHandler: { (granted, error) -> Void in
                    granted ? KNContactsAuthorisation.requestAccess(conditionToEnableContact: conditionToEnableContact, completion: completion) : completion(.failure(.accessNotGranted))
                })
                return completion(result)
                
            case  CNAuthorizationStatus.authorized, CNAuthorizationStatus(rawValue: 4):
                var allContacts = [CNContact]()
                let fetchRequestKeys = CNContactFetchRequest(keysToFetch: KNContactUtils.getBasicDisplayKeys())
                
                do {
                    try self.contactStore.enumerateContacts(with: fetchRequestKeys, usingBlock: { (contact, stop) -> Void in
                        if conditionToEnableContact(contact) {
                            allContacts.append(contact)
                        }
                    })
                    return completion(.success(allContacts))
                }
                
                catch {
                    return completion(.failure(.fetchRequestFailed))
                }
                
            @unknown default:
                return completion(.failure(.unknownAuthorisation))
        }
        
    }
    
    static func checkAuthorisationStatus() -> CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
}
#endif
