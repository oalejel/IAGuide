//
//  GuideViewController.swift
//  
//
//  Created by Omar Alejel on 6/18/15.
//
//

import UIKit

class __GuideViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //booleans
    var finishedAnimation = false
    var isADay = false
    var viewAppearedBefore = false
    
    var scheduleView: ClassBlockViewContainer!
    //school events
    var eventsCalendar: MXLCalendar! {
        didSet {
            updateEventsArray()
        }
    }
    var eventsArray: [MXLCalendarEvent]!    //will hold only current/upcoming
    
    var aImage: UIImage!
    var bImage: UIImage!
    
    var dayImageView: UIImageView!
    @IBOutlet var tableLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var calendarHeaderView: UIView!

    //MARK: Initializer
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
//        //set the tab bar item (tab that you use to select the guide controller)
//        let iconUnselected = UIImage(named: "star")
//        let iconSelected = UIImage(named: "star_selected")
//        tabBarItem = UITabBarItem(title: "Today", image: iconUnselected, selectedImage: iconSelected)
//        //set the images so that they are available [make this a computed property later]
//        aImage = UIImage(named: "aday")
//        bImage = UIImage(named: "bday")
    }

    //this is just there because i overrided the init(nib... method
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        //set the table cell for events table to detailtablecell
//        tableView.registerClass(DetailTableCell.self, forCellReuseIdentifier: "cell")
//        
//        //setup the view that shows class times
//        scheduleView = ClassBlockViewContainer()
//        scheduleView.layer.cornerRadius = 5//!move to init method of the class
//        scheduleView.layer.masksToBounds = true
//        
//        //tableview setup
//        tableView.backgroundColor = UIColor.clearColor()
//        tableView.backgroundView?.backgroundColor = UIColor.clearColor()
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        //configure A/B day info and images
//        isADay = TodayManager.sharedClassManager().todayIsAnADay(NSDate())
//        var yesterdayImage: UIImage!
//        if isADay {
//            yesterdayImage = bImage
//        } else {
//            yesterdayImage = aImage
//        }
//        //give the dayImageView an image for yesterdays A/B day value so we can animate it tearing off once the view appears to show the actual A/B day image
//        dayImageView = UIImageView(image: yesterdayImage)
//        finishedAnimation = true//!change the name to animatingDayImage so false is default
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !viewAppearedBefore {
            setBackgroundGradient()
//            updateCurrentEvents()
            
//            ///!!!!!fix this section (make it neat and say what it does/....)
//            let origin = calendarHeaderView.frame.origin
//            let size = calendarHeaderView.frame.size
//            //this all needs to change!!!
//            let rect = CGRectMake(view.center.x - size.width / 2, origin.y + size.height, size.width, size.width)
//            dayImageView.frame = rect
//            view.insertSubview(dayImageView, aboveSubview: calendarHeaderView)
//            
//            let calendarFrame = dayImageView.frame
//            let centerY = ((calendarFrame.origin.y + calendarFrame.size.height) + (tableView.frame.origin.y)) / 2
//            scheduleView.center = CGPointMake(view.center.x, centerY)
//            //just make sure its in the right heirarchy
//            view.addSubview(scheduleView)//& = diff!
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !viewAppearedBefore {
//            viewAppearedBefore = true
//            switchDayImage()//animate from A->B or vice versa
        }
    }
    
    //MARK: Extra Visual Customization
    //this will set the blue gradient background used throughout the app
    func setBackgroundGradient() {
        let color1 = UIColor(red: 105/255, green: 220/255, blue: 1.0, alpha: 1.0)
        let color2 = UIColor(red: 0.0, green: 0.17, blue: 0.9, alpha: 1.0)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.frame
        gradientLayer.colors = [color1.CGColor, color2.CGColor]
        view.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func updateCurrentEvents() {
        //go to background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let calendarManager = MXLCalendarManager()
            let calendarURL = NSURL(string: "https://www.iatoday.org/_infrastructure/ICalendarHandler.ashx?Tokens=757278")
            
            
            calendarManager.scanICSFileAtRemoteURL(calendarURL, withCompletionHandler: { (onlineCalendar, onlineFileData, error) -> Void in
                    //if you cant get data from online, check for saved data
                    if error != nil {
                        print("Error getting data from Online: \(error.description)", terminator: "")
                        calendarManager.scanICSFileAtLocalPath(self.itemArchivePath(), withCompletionHandler: { (fileCalendar, nilFileData, fileError) -> Void in
                            if fileError != nil {
                                print("Error getting data from File: \(fileError.description)", terminator: "")
                            } else if fileError == nil {
                                self.updateTableWithCalendar(fileCalendar)
                            }
                        })
                    } else {
                        //if there was no error in getting from online, save to file
                        //let calendarData = NSData(contentsOfURL: calendarURL!)
                        self.updateTableWithCalendar(onlineCalendar)
                        let data: NSData! = onlineFileData//i did this becuase the was a problem with the compiler
                        data.writeToFile(self.itemArchivePath(), atomically: false)
                }
            })
        })
        
        tableLoadingIndicator.stopAnimating()
    }

    func updateTableWithCalendar(cal: MXLCalendar) {
        //get on the main thread to update the table
        self.eventsCalendar = cal//! might not need
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    func switchDayImage() {
        if finishedAnimation {
            let now = NSDate()
            isADay = TodayManager.sharedClassManager().todayIsAnADay(now)
            
            dateFormatter.dateFormat = "e"//day of week format (1-7)
            let dayOfWeek = Int(dateFormatter.stringFromDate(now))
            
            var imageToInsert: UIImage!
            
            if dayOfWeek == 1 || dayOfWeek == 7 || TodayManager.sharedClassManager().noSchool() {
                var testDate = now.dateByAddingTimeInterval(86400)
                
                repeat {
                    testDate = testDate.dateByAddingTimeInterval(86400)
                    //get weekday from the date (1-7)
                    let testWeekday = Int(dateFormatter.stringFromDate(testDate))
                    let noHolidayBool = TodayManager.sharedClassManager().dayTypeForDate(testDate) != 3 //3 is when there is a holiday
                    let weekdayBool = (testWeekday != 7) && (testWeekday != 1)
                    
                    if noHolidayBool && weekdayBool{
                        let testIsAnADay = TodayManager.sharedClassManager().todayIsAnADay(testDate)
                        
                        let imageName = testIsAnADay ? "nextaday" : "nextbday"
                        imageToInsert = UIImage(named: imageName)
                        break
                    }
                } while (true);
            } else {
                imageToInsert = isADay ? aImage : bImage
            }
            
            let newImageView = UIImageView(image: imageToInsert)
            newImageView.frame = dayImageView.frame
            view.insertSubview(newImageView, belowSubview: dayImageView)
            finishedAnimation = false
            let newCenter = CGPointMake(view.center.x, view.frame.size.height + dayImageView.frame.size.height)
            
            UIView.animateWithDuration(1.0, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.dayImageView.center = newCenter
                    self.dayImageView.transform = CGAffineTransformMakeRotation(CGFloat(40 * (M_PI * 180)))
                }, completion: { (done) -> Void in
                    self.finishedAnimation = true
                    self.dayImageView.removeFromSuperview()
                    self.dayImageView = nil
                    self.dayImageView = newImageView
            })
        }
    }
    
    //MARK: TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //add 1 to number of events so we can have a "No More!" cell
        if let array = eventsArray {
            return array.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "IA Okma Events"
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.backgroundView?.backgroundColor = UIColor.grayColor()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        //setup colors
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.detailTextLabel!.textColor = UIColor.whiteColor()
        cell.backgroundView!.backgroundColor = UIColor.clearColor()
        cell.backgroundColor = UIColor.clearColor()
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        if eventsArray.count == indexPath.row {
            cell.textLabel?.text = "That's it for the Week!"
            cell.detailTextLabel?.text = ""
            return cell
        }
        
        let schoolEvent = eventsArray[indexPath.row]
        var eventName = schoolEvent.eventSummary
        eventName = eventName.stringByReplacingOccurrencesOfString("IA Okma - ", withString: "")
        eventName = eventName.stringByReplacingOccurrencesOfString("IA Okma-", withString:"")
        cell.textLabel?.text = eventName
        
        let eventStart = schoolEvent.eventStartDate
        let eventLocation = schoolEvent.eventLocation
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        if schoolEvent.eventLocation != nil {
            cell.detailTextLabel?.text = "\(dateFormatter.stringFromDate(eventStart)), \(eventLocation)"
        } else {
            cell.detailTextLabel?.text = "\(dateFormatter.stringFromDate(eventStart))"
        }
        
        return cell
    }
    
    func updateEventsArray() {  //when the events calendar is updated, filter the data
        var date = NSDate()
        for _ in 1...7 {
            date = date.dateByAddingTimeInterval(86400)
            dateFormatter.dateFormat = "d"//day of month format
            let dayOfMonth = Int(dateFormatter.stringFromDate(date))
            dateFormatter.dateFormat = "M"//month format
            let monthNumber = Int(dateFormatter.stringFromDate(date))
            for event in eventsCalendar.events {
                if let eventStart = event.eventStartDate {
                    dateFormatter.dateFormat = "M"//reset to month format
                    if Int(dateFormatter.stringFromDate(eventStart)) == monthNumber {
                        dateFormatter.dateFormat = "d"//day format
                        let f = Int(dateFormatter.stringFromDate(eventStart))
                        if f == dayOfMonth {
                            eventsArray.append(event as! MXLCalendarEvent)
                        }
                    }
                }
            }
        }
    }
    
    func prepareForNewDay() {
        switchDayImage()
        updateCurrentEvents()
    }
    
    func itemArchivePath() -> String {
        let docDirectories = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let directory = docDirectories.first! as String
        return directory + "/calendar.ics"
    }

}
