//
//  ManagedAlbumExtension.swift
//  DayLapse
//
//  Created by Saiday on 2/7/17.
//  Copyright © 2017 saiday. All rights reserved.
//

import Foundation

import CoreData

extension ManagedAlbum {
    class func fetchManagedAlbum(persistenContainer: NSPersistentContainer, localId: String) -> ManagedAlbum? {
        let request: NSFetchRequest<ManagedAlbum> = ManagedAlbum.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "localIdentifier == %@", localId)
        do {
            let result = try persistenContainer.viewContext.fetch(request)
            let managedAlbum = result.count > 0 ? result.first! : nil
            return managedAlbum
        } catch {
            print("fetch MangedAlbum error")
        }
        
        return nil
    }
    
    func gravityData() -> GravityData? {
        if let gravityData = self.latestDeviceMotionGravity {
            return GravityData(x: gravityData.x, y: gravityData.y, z: gravityData.z)
        }
        
        return nil
    }
}
