//
//  ContactType+CoreDataProperties.swift
//  
//
//  Created by no me on 12/20/18.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension ContactType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactType> {
        return NSFetchRequest<ContactType>(entityName: "ContactType")
    }

    @NSManaged public var name: String?
    @NSManaged public var contacts: Contacts?

}
