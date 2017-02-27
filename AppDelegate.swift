//
//  AppDelegate.swift
//  DeathTicker
//
//  Created by David Weinstein on 2/13/17.
//  Copyright © 2017 David Weinstein. All rights reserved.
//

import Cocoa
import CSVImporter

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var birthdayPicker: NSDatePickerCell!
	@IBOutlet weak var maleButton: NSButton!
	@IBOutlet weak var femaleButton: NSButton!
	@IBOutlet weak var preferencesWindow: NSWindow!
	
	@IBOutlet weak var menu: NSMenu!
	@IBOutlet weak var quit: NSMenuItem!
	@IBOutlet weak var preferences: NSMenuItem!
	let configFile = "config.data"
	let dbFile = "db.csv"
	
	var year = 1994
	var month = 02
	var day = 12
	var sex = "M"
	
	class Death {
		let age: Int, mYears: Double, fYears: Double
		init(age: Int, mYears: Double, fYears: Double) {
			self.age = age
			self.mYears = mYears
			self.fYears = fYears
		}
	}
	
	
	@IBOutlet weak var window: NSWindow!
	let statusItem = NSStatusBar.system().statusItem(withLength: 85)


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		
		do {
			let configPath = Bundle.main.path(forResource: "config", ofType: "data")
			let fileContents = try String(contentsOfFile: configPath!, encoding: String.Encoding.utf8)
			let settings:Array<String> = NSString(string: fileContents).components(separatedBy: "\n")
			year = Int(settings[0])!
			month = Int(settings[1])!
			day = Int(settings[2])!
			sex = String(settings[3])!
			if(sex == "M") {
				self.maleButton.state = 1
				self.femaleButton.state = 0
			}
			else if(sex == "F") {
				self.maleButton.state = 0
				self.femaleButton.state = 1
			}
		}
		catch {
			print("error")
		}
		
		setDate()
		setContent()
		
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
	
	func setContent() {
		
		
		let calendar = NSCalendar.current
		let birthdayComponent = NSDateComponents()
		let curDate = Date()
		
		birthdayComponent.year = year
		birthdayComponent.month = month
		birthdayComponent.day = day
		
		let birthday = calendar.date(from: birthdayComponent as DateComponents)
		let age = getAge(calendar: calendar, birthday: birthday!, curDate: curDate)
		
		self.statusItem.title = "??????"
		self.statusItem.menu = menu
		
		
		let dbPath = Bundle.main.path(forResource: "db", ofType: "csv")
		let importer = CSVImporter<Death>(path: dbPath!)
		importer.startImportingRecords { recordValues -> Death in
			return Death(age: Int(recordValues[0])!, mYears: Double(recordValues[1])!, fYears: Double(recordValues[2])!)
			}.onFail {
				print("The CSV file " + dbPath! + " couldn't be read.")
			}.onProgress { importedDataLinesCount in
					
				print("\(importedDataLinesCount) lines were already imported.")
				
			}.onFinish { importedRecords in
				for death in importedRecords {
					
					if (age == death.age) {
						
						self.setDayString(dateDiff: self.getDaysToDeath(death: death, sex: self.sex, curDate: curDate, birth: birthday!, calendar: calendar))
						
					}
				}
			}
		

	}
	
	// Create sting and set number of days displayed in menu bar
	func setDayString(dateDiff: Int) {
		let daysLeft = dateDiff / 60 / 60 / 24
		let beforeComma = Int(daysLeft / 1000)
		let afterComma = Int(daysLeft % 1000)
		
		self.statusItem.title = String(beforeComma) + "," + String(afterComma) + " days"
	}
	
	func getAge(calendar: Calendar, birthday: Date, curDate: Date) -> Int {
		var age = calendar.component(.year, from: curDate) - calendar.component(.year, from: birthday)
		if (calendar.component(.month, from: curDate) >= calendar.component(.month, from: birthday)) {
			
			if(calendar.component(.day, from: curDate) > calendar.component(.day, from: birthday) && calendar.component(.month, from: curDate) == calendar.component(.month, from: birthday)) {
				age += 1
			}
			age -= 1
		}
		return age
	}
	
	func getDaysToDeath(death: Death, sex: String, curDate: Date, birth: Date, calendar: Calendar) -> Int {
		var yearsToGo = 0.0
		if(sex == "M") {
			yearsToGo = death.mYears
		} else {
			yearsToGo = death.fYears
		}
		
		let futureYears = Int(yearsToGo)
		let futurePercentOfYear = (yearsToGo) - Double(futureYears)
		let futureDays = Int(365 * futurePercentOfYear)
		
		let birthdayComponent = NSDateComponents()
		birthdayComponent.year = calendar.component(.year, from: curDate)
		birthdayComponent.month = calendar.component(.month, from: birth)
		birthdayComponent.day = calendar.component(.day, from: birth)
		
		let birthday = calendar.date(from: birthdayComponent as DateComponents)
		
		var deathDate = NSCalendar.current.date(byAdding: Calendar.Component.year, value: futureYears, to: birthday! as Date)
		deathDate = NSCalendar.current.date(byAdding: Calendar.Component.day, value: futureDays, to: deathDate! as Date)
		
		let dateDiff = deathDate?.timeIntervalSince(curDate)
		
		return Int(dateDiff!)
	}
	
	func setDate() {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat =  "yyyy-MM-dd"
		let dateString = String(self.year) + "-" + String(self.month) + "-" + String(self.day)
		
		let date = dateFormatter.date(from: dateString)
		
		birthdayPicker.dateValue = date!
	}

	@IBAction func dateChanged(_ sender: NSDatePicker) {
		let calendar = NSCalendar.current
		let changedDate = sender.dateValue
		
		self.year = calendar.component(.year, from: changedDate)
		self.month = calendar.component(.month, from: changedDate)
		self.day = calendar.component(.day, from: changedDate)
		
		setContent()
	}
	@IBAction func maleClicked(_ sender: NSButton) {
		self.maleButton.state = 1
		self.femaleButton.state = 0
		sex="M"
		
		setContent()
	}
	@IBAction func femaleClicked(_ sender: NSButton) {
		self.maleButton.state = 0
		self.femaleButton.state = 1
		sex="F"
		
		setContent()
	}
	@IBAction func preferencesClicked(_ sender: NSMenuItem) {
		self.preferencesWindow!.orderFront(self)
	}
	@IBAction func quitClicked(_ sender: NSMenuItem) {
		let configPath = Bundle.main.path(forResource: "config", ofType: "data")
		let file: FileHandle? = FileHandle(forWritingAtPath: configPath!)
		if file != nil {
			let data = (String(year) + "\n" + String(month) + "\n" + String(day) + "\n" + sex + "\n" as NSString).data(using: String.Encoding.utf8.rawValue)
			file?.write(data!)
			file?.closeFile()
		} else {
			print("Error in saving config")
		}
		NSApplication.shared().terminate(self)
	}
}

