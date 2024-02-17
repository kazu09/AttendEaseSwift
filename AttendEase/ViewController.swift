//
//  ViewController.swift
//  AttendEase
//
//  Created by kazu on 2024/02/10.
//

import UIKit

class ViewController: UIViewController {

    var viewModel: AttendanceViewModel!
    @IBOutlet weak var attendance: UIButton!
    @IBOutlet weak var leaving: UIButton!
    @IBOutlet weak var date_time: UILabel!
    let userId: Int64 = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
        // デバッグ用：後ほど削除
        if let url = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.persistentStoreCoordinator.persistentStores.first?.url {
            print("Database URL: \(url)")
        }
    }

    @IBAction func attendance(_ sender: UIButton) {
        date_time.text = getDateTime()
        let date = getCurrentDate()
        let timeIn = getCurrentUnixTime()
        viewModel.insertAttendanceRecord(userId: userId, date: date, timeIn: timeIn)
        disabledButton()
    }
    
    @IBAction func leaving(_ sender: UIButton) {
        date_time.text = getDateTime()
        let date = getCurrentDate()
        let timeOut = getCurrentUnixTime()
        viewModel.updateAttendanceRecord(userId: userId, date: date, timeOut: timeOut)
        disabledButton()
    }

    @IBAction func dowmload(_ sender: UIButton) {
        
    }
    
    // デバッグ用：後ほど削除
    @IBAction func deleteButton(_ sender: UIButton) {
        viewModel.allDeleteAttendanceRecords(forUserId: userId)
    }
    
    private func initView() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        viewModel = AttendanceViewModel(context: context)
    
        date_time.text = getDateTime()
        disabledButton()
    }
    
    private func getDateTime() -> String {
        let dt = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMddHHmmss", options: 0, locale: Locale(identifier: "ja_JP"))
        return dateFormatter.string(from: dt)
    }
    
    private func getCurrentDate() -> String {
        let dt = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        let dateStr = dateFormatter.string(from: dt)
        return dateStr.replacingOccurrences(of: "/", with: "-")
    }
    
    private func getCurrentUnixTime() -> Int64 {
        return Int64(Date().timeIntervalSince1970)
    }
    
    private func disabledButton() {
        let date = getCurrentDate()
        let records = viewModel.fetchAttendanceRecords(forDate: date)
        for record in records  {
            print("Record: userId=\(record.userId), date=\(record.date ?? "nil"), timeIn=\(record.timeIn), timeOut=\(record.timeOut)")
            if (record.date != nil) {
                attendance.isEnabled = false
                attendance.backgroundColor = UIColor(colorCode: "AAAAAA")
            }
            if (record.timeOut != 0) {
                leaving.isEnabled = false
                leaving.backgroundColor = UIColor(colorCode: "AAAAAA")
            }
        }
    }
}

