//
//  ViewController.swift
//  AttendEase
//
//  Created by kazu on 2024/02/10.
//

import UIKit

class ViewController: UIViewController {

    var viewModel: AttendanceViewModel!
    var language: Language!
    
    @IBOutlet weak var attendance: UIButton!
    @IBOutlet weak var leaving: UIButton!
    @IBOutlet weak var date_time: UILabel!
    @IBOutlet weak var download: UIButton!
    @IBOutlet weak var debugbutton: UIButton!
    
    let userId: Int64 = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
    }

    @IBAction func localizeIcon(_ sender: UITapGestureRecognizer){
        let dialogTitle = language.localizedString(forKey: "set_lang_dialog_title")
        let cancelButTxt = language.localizedString(forKey: "cancel")
        
        let actionSheet = UIAlertController(title: dialogTitle, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "English", style: .default, handler: { _ in
           self.updateLocalizedText(lang: "en")
        }))
        actionSheet.addAction(UIAlertAction(title: "日本語", style: .default, handler: { _ in
           self.updateLocalizedText(lang: "ja")
        }))
        actionSheet.addAction(UIAlertAction(title: cancelButTxt, style: .cancel, handler: nil))
        present(actionSheet, animated: true)
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
        // Get current date colum in DB
        let records = viewModel.fetchAttendanceRecordWithUserId(forUserId: userId)
        for record in records  {
            print("Record: userId=\(record.userId), date=\(record.date ?? "nil"), timeIn=\(record.timeIn), timeOut=\(record.timeOut)")
        }
        exportRecordsToTextFile(records: records)
    }
    
//    debug button : All delete in DB
//    @IBAction func deleteButton(_ sender: UIButton) {
//        viewModel.allDeleteAttendanceRecords(forUserId: userId)
//    }
    
    /**
     Init view
     */
    private func initView() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // Instance
        viewModel = AttendanceViewModel(context: context)
        language = Language()
        
        // Setting view
        date_time.text = getDateTime()
        disabledButton()
        // default Japanese
        updateLocalizedText(lang: "ja")
        
        // debug button
        debugbutton.isHidden = true
    }
    
    /**
     Get Current Date and time.
     
    :returns: format yyyy/mm/dd hh:mm:ss
     */
    private func getDateTime() -> String {
        let dt = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMddHHmmss", options: 0, locale: Locale(identifier: "ja_JP"))
        return dateFormatter.string(from: dt)
    }
    
    /**
     Get Current date
     
    :returns: format yyyy-mm-dd
     */
    private func getCurrentDate() -> String {
        let dt = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        let dateStr = dateFormatter.string(from: dt)
        return dateStr.replacingOccurrences(of: "/", with: "-")
    }
    
    /**
     Get current unix time
     
    :returns: unix time
     */
    private func getCurrentUnixTime() -> Int64 {
        return Int64(Date().timeIntervalSince1970)
    }
    
    /**
     Convert unix time to date string.
    
    :param: TimeInterval unixTime
    :returns: Date string
     */
    private func convertUnixTimeToString(unixTime: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    /**
     Check "attendance" button and "leaving" button disabled.
     */
    private func disabledButton() {
        let date = getCurrentDate()
        // Get current date colum in DB
        let records = viewModel.fetchAttendanceRecords(forDate: date)
        let notTap = 0
        for record in records  {
            print("Record: userId=\(record.userId), date=\(record.date ?? "nil"), timeIn=\(record.timeIn), timeOut=\(record.timeOut)")
            if (record.date != nil) {
                attendance.isEnabled = false
                attendance.backgroundColor = UIColor(colorCode: "AAAAAA")
            }
            if (record.timeOut != notTap) {
                leaving.isEnabled = false
                leaving.backgroundColor = UIColor(colorCode: "AAAAAA")
            }
        }
    }
    
    /**
     Change Language English or Japanese.
     
    :param: lang LanguageCode.
     */
    private func updateLocalizedText(lang: String) {
        // key : Localizable.strings key. value : IBOutlet
        let ibOutletAndWordId: KeyValuePairs = [
            "attendance_button_text" : attendance,
            "leaving_button_text" : leaving,
            "download_button_text" : download
        ]
        
        // Setting Language and fix button text.
        for (key, value) in ibOutletAndWordId {
            language.setLanguage(lang)
            let displayText = language.localizedString(forKey: key)
            value?.setTitle(displayText, for: .normal)
            
            // Setting Button Layout
            var config = UIButton.Configuration.plain()
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont(name: "Helvetica Neue Bold", size: 20)
                return outgoing
            }
            value?.configuration = config
        }
    }
    
    /**
     Export attendance record to text.
     
    :param: records AttendanceRecord
     */
    private func exportRecordsToTextFile(records: [AttendanceRecord]) {
        let fileName = "AttendEase.txt"
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        
        var text = ""
        for record in records {
            // Optional unwrap
            let date = record.date ?? ""
            if (date != "") {
                // Go to the "else" if the "Finish" button is not tapped.
                if (record.timeOut != 0) {
                    let timeIn = convertUnixTimeToString(unixTime: TimeInterval(record.timeIn))
                    let timeOut = convertUnixTimeToString(unixTime: TimeInterval(record.timeOut))
                    text += "Date: \(date), Begin: \(timeIn), Finish: \(timeOut)\n"
                } else {
                    let timeIn = convertUnixTimeToString(unixTime: TimeInterval(record.timeIn))
                    text += "Date: \(date), Begin: \(timeIn)\n"
                }
            }
        }
        
        // Output text.
        do {
            try text.write(to: path, atomically: true, encoding: .utf8)
            print("File written to \(path)")
        } catch {
            print("Failed to write file: \(error)")
        }
    }
    
//    sqlite path (Debug)
//    private func debug() {
//        if let url = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.persistentStoreCoordinator.persistentStores.first?.url {
//            print("Database URL: \(url)")
//        }
//    }
}

