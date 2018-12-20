//
//  Person+CoreDataProperties.swift
//  
//
//  Created by no me on 12/20/18.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var dob: Date?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var myDevice: Bool
    @NSManaged public var addresses: NSSet?
    @NSManaged public var contacts: Contacts?
    @NSManaged public var emails: NSSet?
    @NSManaged public var phoneNumbers: NSSet?

}

// MARK: Generated accessors for addresses
extension Person {

    @objc(addAddressesObject:)
    @NSManaged public func addToAddresses(_ value: Addresses)

    @objc(removeAddressesObject:)
    @NSManaged public func removeFromAddresses(_ value: Addresses)

    @objc(addAddresses:)
    @NSManaged public func addToAddresses(_ values: NSSet)

    @objc(removeAddresses:)
    @NSManaged public func removeFromAddresses(_ values: NSSet)

}

// MARK: Generated accessors for emails
extension Person {

    @objc(addEmailsObject:)
    @NSManaged public func addToEmails(_ value: Emails)

    @objc(removeEmailsObject:)
    @NSManaged public func removeFromEmails(_ value: Emails)

    @objc(addEmails:)
    @NSManaged public func addToEmails(_ values: NSSet)

    @objc(removeEmails:)
    @NSManaged public func removeFromEmails(_ values: NSSet)

}

// MARK: Generated accessors for phoneNumbers
extension Person {

    @objc(addPhoneNumbersObject:)
    @NSManaged public func addToPhoneNumbers(_ value: PhoneNumbers)

    @objc(removePhoneNumbersObject:)
    @NSManaged public func removeFromPhoneNumbers(_ value: PhoneNumbers)

    @objc(addPhoneNumbers:)
    @NSManaged public func addToPhoneNumbers(_ values: NSSet)

    @objc(removePhoneNumbers:)
    @NSManaged public func removeFromPhoneNumbers(_ values: NSSet)

}
