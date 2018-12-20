//
//  Emails+CoreDataProperties.swift
//  
//
//  Created by no me on 12/20/18.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Emails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Emails> {
        return NSFetchRequest<Emails>(entityName: "Emails")
    }

    @NSManaged public var email: String?
    @NSManaged public var person: Person?

}
