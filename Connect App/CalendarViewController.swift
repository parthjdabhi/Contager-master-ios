//
//  CalendarViewController.swift
//  
//
//  Created by Leqi Long on 8/3/16.
//
//

import JTAppleCalendar
import CoreData
import GoogleAPIClient
import GTMOAuth2

class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource/*,NSFetchedResultsControllerDelegate*/, InputPlansViewControllerDelegate{

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var plansTableView: UITableView!
    @IBOutlet weak var addPlansButton: UIButton!
    @IBOutlet var googleInfo: UITextView!
    @IBOutlet var deleteButton: UIButton!
    
    private let kKeychainItemName = "Contager"
    private let kClientID = "901485411162-pvg40grc0hdrenvnbbfn21bo0vhqi6cg.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLAuthScopeCalendarReadonly]
    
    private let service = GTLServiceCalendar()
    var output = UITextView()
    
    var numberOfRows = 6
    var selectedDate = NSDate(){
        didSet{
            print("selectedDate changed from \(oldValue) to \(selectedDate). Will executeSearch!")
            //executeSearch()
        }
    }
    
    var activities = [Activity]()
    
    var currentDate: DateShort?
    var context: NSManagedObjectContext{
        return CoreDataStack.sharedInstance.context
    }
    
    var datesWithPlans = [DateShort]()
    
    let formatter = NSDateFormatter()
    let testCalendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        output.frame = view.bounds
        output.editable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        view.addSubview(output);
        
        googleInfo.text = output*/
        
        deleteButton.hidden = true
        
        googleInfo = output
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(CalendarViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(CalendarViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        addPlansButton.enabled = false
        
        formatter.dateFormat = "yyyy MM dd"
        testCalendar.timeZone = NSTimeZone(abbreviation: "GMT")!
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        plansTableView.delegate = self
        plansTableView.dataSource = self
        
        //executeSearch()
        
        let footerView = UIView(frame: CGRectZero)
        footerView.backgroundColor = UIColor.clearColor()
        self.plansTableView.tableFooterView = footerView
        
        // Registering your cells is manditory   ******************************************************
        
        calendarView.registerCellViewXib(fileName: "CellView") // Registering your cell is manditory
        //         calendarView.registerCellViewClass(fileName: "JTAppleCalendar_Example.CodeCellView")
        
        // ********************************************************************************************
        
        
        // Enable the following code line to show headers. There are other lines of code to uncomment as well
//        calendarView.registerHeaderViewXibs(fileNames: ["PinkSectionHeaderView", "WhiteSectionHeaderView"]) // headers are Optional. You can register multiple if you want.
        
        // The following default code can be removed since they are already the default.
        // They are only included here so that you can know what properties can be configured
        calendarView.direction = .Horizontal                       // default is horizontal
        calendarView.cellInset = CGPoint(x: 3, y: 3)               // default is (3,3)
        //calendarView.allowsMultipleSelection = false               // default is false
        calendarView.bufferTop = 0                                 // default is 0. - still work in progress on this
        calendarView.bufferBottom = 0                              // default is 0. - still work in progress on this
        calendarView.firstDayOfWeek = .Sunday                      // default is Sunday
        calendarView.scrollEnabled = true                          // default is true
        calendarView.pagingEnabled = true                          // default is true
        calendarView.scrollResistance = 0.75                       // default is 0.75 - this is only applicable when paging is not enabled.
        calendarView.itemSize = nil                                // default is nil. Use a value here to change the size of your cells
        calendarView.cellSnapsToEdge = false                        // default is true. Disabling this causes calendar to not snap to grid
        calendarView.reloadData()
        
        // After reloading. Scroll to your selected date, and setup your calendar
        calendarView.scrollToDate(NSDate(), triggerScrollToDateDelegate: false, animateScroll: false) {
            let currentDate = self.calendarView.currentCalendarDateSegment()
            self.setupViewsOfCalendar(currentDate.startDate, endDate: currentDate.endDate)
        }
    }
    
    // When the view appears, ensure that the Google Calendar API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            fetchEvents()
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    // Construct a query and get a list of upcoming events from the user calendar
    func fetchEvents() {
        let query = GTLQueryCalendar.queryForEventsListWithCalendarId("primary")
        query.maxResults = 10
        query.timeMin = GTLDateTime(date: NSDate(), timeZone: NSTimeZone.localTimeZone())
        query.singleEvents = true
        query.orderBy = kGTLCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: #selector(CalendarViewController.displayResultWithTicket(_:finishedWithObject:error:))
        )
    }
    
    // Display the start dates and event summaries in the UITextView
    func displayResultWithTicket(
        ticket: GTLServiceTicket,
        finishedWithObject response : GTLCalendarEvents,
                           error : NSError?) {
        
        if let error = error {
            showAlert("Error", message: error.localizedDescription)
            return
        }
        
        var eventString = ""
        
        if let events = response.items() where !events.isEmpty {
            for event in events as! [GTLCalendarEvent] {
                let start : GTLDateTime! = event.start.dateTime ?? event.start.date
                let startString = NSDateFormatter.localizedStringFromDate(
                    start.date,
                    dateStyle: .ShortStyle,
                    timeStyle: .ShortStyle
                )
                eventString += "\(startString) - \(event.summary)\n"
            }
        } else {
            eventString = "No upcoming events found."
        }
        
        output.text = eventString
    }
    
    
    // Creates the auth controller for authorizing access to Google Calendar API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: "viewController:finishedWithAuth:error:"
        )
    }
    
    // Handle completion of the authorization process, and update the Google Calendar API
    // with the new credentials.
    func viewController(vc : UIViewController,
                        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert("Authentication Error", message: error.localizedDescription)
            return
        }
        
        service.authorizer = authResult
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: nil
        )
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func fetchActivities(selectedDate: NSDate?){
        
        let fr = NSFetchRequest(entityName: "Activity")
        fr.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        if let selectedDate = selectedDate{
            print("selectedDate in func fetchActivitiesis \(selectedDate)!")
            fr.predicate = NSPredicate(format: "selectedDate == %@", selectedDate)
        }
        
        do{
            try activities = context.executeFetchRequest(fr) as! [Activity]
        }catch{
            activities = [Activity]()
        }
        
        plansTableView.reloadData()
        
    }

    
    func loadActivityViews(){
        
    }
    @IBAction func inputPlans(sender: AnyObject) {
        performSegueWithIdentifier("showInput", sender: self)
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func deleteAction(sender: AnyObject) {
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        context.deleteObject(currentDate!)
        //currentDate!.removeAtIndex
        do {
            try context.save()
        } catch _ {
        }
        viewDidLoad()
        viewDidAppear(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showInput" {
            let vc = segue.destinationViewController as! InputPlansViewController
            vc.delegate = self
            vc.currentDate = currentDate
            vc.selectedDate = selectedDate
        }
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer){
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                 self.calendarView.scrollToPreviousSegment()
            case UISwipeGestureRecognizerDirection.Left:
                self.calendarView.scrollToNextSegment()
            default:
                break
            }
        }
    }

    func setupViewsOfCalendar(startDate: NSDate, endDate: NSDate) {
        let month = testCalendar.component(NSCalendarUnit.Month, fromDate: startDate)
        let monthName = NSDateFormatter().monthSymbols[(month-1) % 12] // 0 indexed array
        let year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: startDate)
        monthLabel.text = monthName
        yearLabel.text = String(year)
    }

}

// MARK : JTAppleCalendarDelegate
extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar) {
        
        let firstDate = formatter.dateFromString("2016 01 01")
        let secondDate = formatter.dateFromString("2017 12 31")
        let aCalendar = NSCalendar.currentCalendar() // Properly configure your calendar to your time zone here
        return (startDate: firstDate!, endDate: secondDate!, numberOfRows: numberOfRows, calendar: aCalendar)
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        (cell as? CellView)?.setupCellBeforeDisplay(cellState, date: date)
    }
    
    func calendar(calendar: JTAppleCalendarView, didDeselectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
        addPlansButton.enabled = false
    }
    
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)

        
        let fr = NSFetchRequest(entityName: "Date")
        do{
            print("Will try to fetch existing dates")
            datesWithPlans = try context.executeFetchRequest(fr) as! [DateShort]
        }catch let e as NSError{
            print("Error in fetchrequest: \(e)")
            datesWithPlans = [DateShort]()
        }

        if datesWithPlans.isEmpty{
            print("No existing dates, will create a new Date now!")
            let newDate = DateShort(date: date, context: self.context)
            currentDate = newDate
        }else{
            print("There are existing dates. Will try to find one that matches the selected Dates")
            for dateWithPlans in datesWithPlans {
                if dateWithPlans.date == date{
                    print("Found an existing date that matches the currently selected date!")
                    currentDate = dateWithPlans
                    deleteButton.hidden = false
                    print("currentDate is \(currentDate)")
                    break
                }
            }
            
            if currentDate?.date == date{
                print("currentDate is \(currentDate)")
            }else{
                
                print("Exsiting dates don't include this currently selected date. Now to create a new Date!")
                let newDate = DateShort(date: date, context: self.context)
                currentDate = newDate
                print("currentDate is \(currentDate)")
            }
        }
        
        do{
            try context.save()
        }catch{}
        
        addPlansButton.enabled = true
        
        selectedDate = date
        //executeSearch()
        
        fetchActivities(selectedDate)
    }
    
    
    
    func calendar(calendar: JTAppleCalendarView, isAboutToResetCell cell: JTAppleDayCellView) {
        (cell as? CellView)?.selectedView.hidden = true
    }
    
    func calendar(calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) {
        setupViewsOfCalendar(startDate, endDate: endDate)
    }
    
    func calendar(calendar: JTAppleCalendarView, sectionHeaderIdentifierForDate date: (startDate: NSDate, endDate: NSDate)) -> String? {
        let comp = testCalendar.component(.Month, fromDate: date.startDate)
        if comp % 2 > 0{
            return "WhiteSectionHeaderView"
        }
        return "PinkSectionHeaderView"
    }
    
    func calendar(calendar: JTAppleCalendarView, sectionHeaderSizeForDate date: (startDate: NSDate, endDate: NSDate)) -> CGSize {
        if testCalendar.component(.Month, fromDate: date.startDate) % 2 == 1 {
            return CGSize(width: 200, height: 50)
        } else {
            return CGSize(width: 200, height: 100) // Yes you can have different size headers
        }
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplaySectionHeader header: JTAppleHeaderView, date: (startDate: NSDate, endDate: NSDate), identifier: String) {
    }
    
    func deleteCalendarEvent() {
        
    }
}

extension CalendarViewController{
    //MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return activities.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor(hue: 0.4417, saturation: 0.32, brightness: 0.68, alpha: 1.0)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("planCell", forIndexPath: indexPath) as! PlansTableViewCell
        
        cell.backgroundColor = UIColor(hue: 0.4417, saturation: 0.32, brightness: 0.68, alpha: 1.0)
        
        let activity = activities[indexPath.row]
        formatter.timeStyle = .ShortStyle
        let strTime = formatter.stringFromDate(activity.time!)
        cell.planLabel.text = activity.detail
        cell.timeLabel.text = strTime
        if let imageString = activity.category{
            cell.planIconImageView.image = UIImage(named: imageString)
        }
        
        //PlansTableViewCell delete record
        return cell
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            // remove the deleted item from the model
            //let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            //let context:NSManagedObjectContext = appDel.managedObjectContext
            self.context.deleteObject(activities[indexPath.row] )
            activities.removeAtIndex(indexPath.row)
            do {
                try self.context.save()
            } catch _ {
            }
            
            // remove the deleted item from the `UITableView`
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        default:
            return
        }
    }
}



func delayRunOnMainThread(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

