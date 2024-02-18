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

    /**
     Save data in database.
     
    :param: userId userId
    :param: date current date
    :param: timeIn current unix time
     */
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
    
    /**
     Update data in database.
     
    :param: userId userid
    :param: date current date
    :param: timeOut current unix time
     */
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
    
    /**
     Get column matched with date.
     
    :param: date current date
     */
    func fetchAttendanceRecords(forDate date: String) -> [AttendanceRecord] {
        let fetchRequest: NSFetchRequest<AttendanceRecord> = AttendanceRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", date)
        do {
            let records = try context.fetch(fetchRequest)
            return records
        } catch {
            print("Failed to fetch records for user \(date): \(error)")
            return []
        }
    }
    
    /**
     Get column matched with userId.
     
    :param: date current date
     */
    func fetchAttendanceRecordWithUserId(forUserId userId: Int64) -> [AttendanceRecord] {
        let fetchRequest: NSFetchRequest<AttendanceRecord> = AttendanceRecord.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "userId == %d", userId)
            
            do {
                let records = try context.fetch(fetchRequest)
                return records
            } catch {
                print("Failed to fetch records for user \(userId): \(error)")
                return []
            }
    }
    
    /**
     Delete column matched with userId.
     
    :param: userId userId
     */
    func allDeleteAttendanceRecords(forUserId userId: Int64) {
        let fetchRequest: NSFetchRequest<AttendanceRecord> = AttendanceRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", NSNumber(value: userId))
        
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                context.delete(record)
            }
            try context.save()
        } catch {
            print("Failed to delete records for user \(userId): \(error)")
        }
    }
}
