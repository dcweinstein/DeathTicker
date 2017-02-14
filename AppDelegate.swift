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
	
	class Death {
		let age: Int, mYears: Double, fYears: Double
		init(age: Int, mYears: Double, fYears: Double) {
			self.age = age
			self.mYears = mYears
			self.fYears = fYears
		}
	}
	
	
	@IBOutlet weak var window: NSWindow!
	let statusItem = NSStatusBar.system().statusItem(withLength: 50)


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		
		let year = 1994
		let month = 2
		let day = 15
		let sex = "M"
		
		let calendar = NSCalendar.current
		let birthdayComponent = NSDateComponents()
		let curDate = Date()
		
		birthdayComponent.year = year
		birthdayComponent.month = month
		birthdayComponent.day = day
		
		let birthday = calendar.date(from: birthdayComponent as DateComponents)
		
		self.statusItem.title = "??????"
		
		let path = "/Users/David/Dropbox/David/sandbox/data.csv"
		
		let importer = CSVImporter<Death>(path: path)
		importer.startImportingRecords { recordValues -> Death in
			return Death(age: Int(recordValues[0])!, mYears: Double(recordValues[1])!, fYears: Double(recordValues[2])!)
		}.onFail {
			print("The CSV file " + path + " couldn't be read.")
		}.onProgress { importedDataLinesCount in
			
			print("\(importedDataLinesCount) lines were already imported.")
				
		}.onFinish { importedRecords in
			for death in importedRecords {
				var age = calendar.component(.year, from: curDate) - calendar.component(.year, from: birthday!)
				if (calendar.component(.month, from: curDate) >= calendar.component(.month, from: birthday!)) {
					
					if(calendar.component(.day, from: curDate) > calendar.component(.day, from: birthday!) && calendar.component(.month, from: curDate) == calendar.component(.month, from: birthday!)) {
						age += 1
					}
					age -= 1
				}

				if (age == death.age) {
					var yearsToGo = 0.0
					if(sex == "M") {
						yearsToGo = death.mYears
					} else {
						yearsToGo = death.fYears
					}
					
					let futureYears = Int(yearsToGo)
					let futurePercentOfYear = (yearsToGo) - Double(futureYears)
					let futureDays = Int(365 * futurePercentOfYear)
					
					var deathDate = NSCalendar.current.date(byAdding: Calendar.Component.year, value: futureYears, to: curDate as Date)
					deathDate = NSCalendar.current.date(byAdding: Calendar.Component.day, value: futureDays, to: deathDate! as Date)
					
					let dateDiff = deathDate?.timeIntervalSince(curDate)
					let daysLeft = dateDiff! / 60 / 60 / 24
					
					self.statusItem.title = String(Int(daysLeft))
				}
			}
		}
		
		
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

