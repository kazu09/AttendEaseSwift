//
//  AttendanceViewModel.swift
//  AttendEase
//
//  Created by kazu on 2024/02/14.
//

import Foundation
import CoreData

class AttendanceViewModel {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func insertAttendanceRecord(userId: Int64, date: String, timeIn: Int64) {
        let record = AttendanceRecord(context: context)
        record.userId = userId
        record.date = date
        record.timeIn = timeIn
        
        do {
            try context.save()
        } catch {
            print("Failed to Save : \(error)")
        }
    }
    
    func updateAttendanceRecord(userId: Int64, date: String, timeOut: Int64) {
        let fetchRequest: NSFetchRequest<AttendanceRecord> = AttendanceRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %d AND date == %@", userId, date)
        
        do {
            let records = try context.fetch(fetchRequest)
            if let record = records.first {
                record.timeOut = timeOut
                try context.save()
            }
        } catch {
            print ("Failed to update: \(error)")
        }
    }
}
