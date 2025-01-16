//
//  KNContactsPicker.swift
//  KNContactsPicker
//
//  Created by Dragos-Robert Neagu on 24/10/2019.
//  Copyright © 2019 Dragos-Robert Neagu. All rights reserved.
//

#if canImport(UIKit) && canImport(Contacts)
import UIKit
import Contacts

open class KNContactsPicker: UINavigationController {
    
    var settings: KNPickerSettings = KNPickerSettings()
    weak var contactPickingDelegate: KNContactPickingDelegate!
    private var contacts: [CNContact] = []
    
    let contactPickerController = KNContactsPickerController(style: .insetGrouped)
    
    private var sortingOutcome: KNSortingOutcome? {
        didSet {
            DispatchQueue.main.async {
                self.contactPickerController.contacts = self.sortingOutcome?.sortedContacts ?? []
                self.contactPickerController.sortedContacts = self.sortingOutcome?.contactsSortedInSections ?? [:]
                self.contactPickerController.sections = self.sortingOutcome?.sections ?? []
                self.contactPickerController.tableView.reloadData()
            }
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.fetchContacts()
        
        self.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        contactPickerController.settings = settings
        contactPickerController.delegate = contactPickingDelegate
        contactPickerController.presentationDelegate = self
        
        self.presentationController?.delegate = contactPickerController
        self.viewControllers.append(contactPickerController)
    }
    
    convenience public init(delegate: KNContactPickingDelegate?, settings: KNPickerSettings) {
        self.init()
        self.contactPickingDelegate = delegate
        self.settings = settings
    }
    
    func fetchContacts() {
        DispatchQueue.global(qos: .background).async {
            switch self.settings.pickerContactsSource {
                case .userProvided:
                    self.sortingOutcome = KNContactUtils.sortContactsIntoSections(contacts: self.settings.pickerContactsList, sortingType: self.settings.displayContactsSortedBy)
                case .default:
                    self.requestAndSortContacts()
            }
        }
    }
    
    private func requestAndSortContacts() {
        KNContactsAuthorisation.requestAccess(conditionToEnableContact: settings.conditionToDisplayContact) { rst in
            switch rst {
                case .success(let resultContacts):
                    self.sortingOutcome = KNContactUtils.sortContactsIntoSections(contacts: resultContacts, sortingType: self.settings.displayContactsSortedBy)
                    
                case .failure(let failureReason):
                    if failureReason != .pendingAuthorisation {
                        self.dismiss(animated: true, completion: {
                            self.contactPickingDelegate?.contactPicker(didFailPicking: failureReason)
                        })
                    }
            }
        }
        
    }
    
}
#endif
