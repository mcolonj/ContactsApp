//
//  Addresses+CoreDataProperties.swift
//  
//
//  Created by no me on 12/20/18.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Addresses {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Addresses> {
        return NSFetchRequest<Addresses>(entityName: "Addresses")
    }

    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var street1: String?
    @NSManaged public var street2: String?
    @NSManaged public var zip: String?
    @NSManaged public var person: Person?

}
