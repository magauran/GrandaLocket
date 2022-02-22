//
//  ContactInfo.swift
//  GrandaLocket
//
//  Created by Сердюков Евгений on 16.02.2022.
//

import Contacts
import Foundation

struct ContactInfo: Identifiable, Equatable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var status: ContactStatus
    var selected: Bool = false

    mutating func changeStatus(_ status: ContactStatus) {
        self.status = status
    }
}

enum FriendStatus: Int {
    case incomingRequest, outcomingRequest, friend
}

enum ContactStatus: Equatable {
    case registered
    case notRegistered
    case inContacts(FriendStatus)

    var stringValue: String {
        switch self {
        case .registered:
            return "registered"
        case .notRegistered:
            return "notRegistered"
        case .inContacts(let friendStatus):
            switch friendStatus {
            case .incomingRequest:
                return "incomingRequest"
            case .outcomingRequest:
                return "outcomingRequest"
            case .friend:
                return "friend"
            }
        }
    }

    var order: Int {
        switch self {
        case .registered:
            return 4
        case .notRegistered:
            return 5
        case .inContacts(let friendStatus):
            switch friendStatus {
            case .incomingRequest:
                return 3
            case .outcomingRequest:
                return 2
            case .friend:
                return 1
            }
        }
    }
}

func contactStatus(from str: String) -> ContactStatus {
    switch str {
    case "friend":
        return .inContacts(.friend)
    case "incomingRequest":
        return .inContacts(.incomingRequest)
    case "outcomingRequest":
        return .inContacts(.outcomingRequest)
    case "register":
        return .registered
    case "notRegister":
        return .notRegistered
    default:
        return .notRegistered
    }
}

final class ContactsInfo: ObservableObject {

    static let instance = ContactsInfo()
    @Published var contacts: [ContactInfo]
    private let userService = UserService()

    private init() {
        self.contacts = []
        self.requestAccess()
    }

    func fetchingContacts() {
        let contactsFromList = fetchContacts()
        contactsFromList.forEach { contact in
            contact.phoneNumbers.forEach { phone in
                userService.checkUserStatus(by: phone.value.stringValue.unformatted) { status in
                    self.contacts.append(
                        ContactInfo(firstName: contact.givenName,
                                    lastName: contact.familyName,
                                    phoneNumber: phone.value.stringValue,
                                    status: status)
                    )
                }
            }
        }
    }

    func requestAccess() {
        let store = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            self.fetchingContacts()
        case .denied:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    self.fetchingContacts()
                }
            }
        case .restricted, .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    self.fetchingContacts()
                }
            }
        @unknown default:
            print("error")
        }
    }
}

private func fetchContacts() -> [CNContact] {
    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
    var contacts: [CNContact] = []

    do {
        try CNContactStore().enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
            if let _ = contact.phoneNumbers.first?.value {
                contacts.append(contact)
            }
        })
    } catch let error {
        print("Failed", error)
    }

    return contacts.sorted {
        $0.givenName < $1.givenName
    }
}
