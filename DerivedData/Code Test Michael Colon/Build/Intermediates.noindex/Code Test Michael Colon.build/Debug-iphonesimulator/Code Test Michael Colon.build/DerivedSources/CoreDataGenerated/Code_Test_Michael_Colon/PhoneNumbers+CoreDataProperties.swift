//
//  PhoneNumbers+CoreDataProperties.swift
//  
//
//  Created by no me on 12/20/18.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PhoneNumbers {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhoneNumbers> {
        return NSFetchRequest<PhoneNumbers>(entityName: "PhoneNumbers")
    }

    @NSManaged public var number: String?
    @NSManaged public var type: Int16
    @NSManaged public var person: Person?

}
