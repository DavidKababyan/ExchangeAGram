//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by David Kababyan on 2/16/15.
//  Copyright (c) 2015 David Kababyan. All rights reserved.
//

import Foundation
import CoreData


@objc(FeedItem)

class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbNail: NSData
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber

}
