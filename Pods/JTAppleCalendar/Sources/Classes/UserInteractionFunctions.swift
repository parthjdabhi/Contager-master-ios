//
//  UserInteractionFunctions.swift
//  Pods
//
//  Created by Jay Thomas on 2016-05-12.
//
//


extension JTAppleCalendarView {
    /// Returns the cellStatus of a date that is visible on the screen. If the row and column for the date cannot be found, then nil is returned
    /// - Paramater row: Int row of the date to find
    /// - Paramater column: Int column of the date to find
    /// - returns:
    ///     - CellState: The start date of the current section
    public func cellStatusForDateAtRow(row: Int, column: Int) -> CellState? {
        if // the row or column falls within an invalid range
            row < 0 || row >= cachedConfiguration.numberOfRows ||
                column < 0 || column >= MAX_NUMBER_OF_DAYS_IN_WEEK {
            return nil
        }
        
        let Offset: Int
        let convertedRow: Int
        let convertedSection: Int
        if direction == .Horizontal {
            Offset = Int(round(calendarView.contentOffset.x / (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize.width))
            convertedRow = (row * MAX_NUMBER_OF_DAYS_IN_WEEK) + ((column + Offset) % MAX_NUMBER_OF_DAYS_IN_WEEK)
            convertedSection = (Offset + column) / MAX_NUMBER_OF_DAYS_IN_WEEK
        } else {
            Offset = Int(round(calendarView.contentOffset.y / (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize.height))
            convertedRow = ((row * MAX_NUMBER_OF_DAYS_IN_WEEK) +  column + (Offset * MAX_NUMBER_OF_DAYS_IN_WEEK)) % (MAX_NUMBER_OF_DAYS_IN_WEEK * cachedConfiguration.numberOfRows)
            convertedSection = (Offset + row) / cachedConfiguration.numberOfRows
        }
        
        let indexPathToFind = NSIndexPath(forItem: convertedRow, inSection: convertedSection)
        if let  date = dateFromPath(indexPathToFind) {
            let stateOfCell = cellStateFromIndexPath(indexPathToFind, withDate: date)
            return stateOfCell
        }
        return nil
    }
    
    /// Returns the calendar view's current section boundary dates.
    /// - returns:
    ///     - startDate: The start date of the current section
    ///     - endDate: The end date of the current section
    public func currentCalendarDateSegment() -> (startDate: NSDate, endDate: NSDate) {
        guard let dateSegment = dateFromSection(currentSectionPage) else {
            assert(false, "Error in currentCalendarDateSegment method. Report this issue to Jay on github.")
            return (NSDate(), NSDate())
        }
        return dateSegment
    }
    
    /// Let's the calendar know which cell xib to use for the displaying of it's date-cells.
    /// - Parameter name: The name of the xib of your cell design
    public func registerCellViewXib(fileName name: String) {
        cellViewSource = JTAppleCallendarCellViewSource.fromXib(name)
    }
    
    /// Let's the calendar know which cell class to use for the displaying of it's date-cells.
    /// - Parameter name: The class name of your cell design
    public func registerCellViewClass(fileName name: String) {
        cellViewSource = JTAppleCallendarCellViewSource.fromClassName(name)
    }
    
    /// Let's the calendar know which cell class to use for the displaying of it's date-cells.
    /// - Parameter name: The type of your cell design
    public func registerCellViewClass(cellClass cellClass: AnyClass) {
        cellViewSource = JTAppleCallendarCellViewSource.fromType(cellClass)
    }
    
    
    /// Register header views with the calender. This needs to be done before the view can be displayed
    /// - Parameter fileNames: A dictionary containing [headerViewNames:HeaderviewSizes]
    public func registerHeaderViewXibs(fileNames headerViewXibNames: [String]) {
        headerViewXibs.removeAll() // remove the already registered xib files if the user re-registers again.
        
        if headerViewXibNames.count < 1 {
            return
        }

        for headerViewXibName in headerViewXibNames {
            let viewObject = NSBundle.mainBundle().loadNibNamed(headerViewXibName, owner: self, options: [:])
            assert(viewObject.count > 0, "your nib file name \(headerViewXibName) could not be loaded)")
            
            guard viewObject[0] is JTAppleHeaderView else {
                assert(false, "xib file class does not conform to the protocol<JTAppleHeaderViewProtocol>")
                return
            }
            
            headerViewXibs.append(headerViewXibName)
            
            self.calendarView.registerClass(JTAppleCollectionReusableView.self,
                                            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                            withReuseIdentifier: headerViewXibName)
        }
    }
    
    /// Reloads the data on the calendar view. Scroll delegates are not triggered with this function.
    public func reloadData(withAnchorDate date:NSDate? = nil, withAnimation animation: Bool = false, completionHandler: (()->Void)? = nil) {
        reloadData(checkDelegateDataSource: true, withAnchorDate: date, withAnimation: animation, completionHandler: completionHandler)
    }
    
    /// Reload the date of specified date-cells on the calendar-view
    /// - Parameter dates: Date-cells with these specified dates will be reloaded
    public func reloadDates(dates: [NSDate]) {
        reloadIndexPathsIfVisible(pathsFromDates(dates))
    }
    
    /// Select a date-cell if it is on screen
    /// - Parameter date: The date-cell with this date will be selected
    /// - Parameter triggerDidSelectDelegate: Triggers the delegate function only if the value is set to true. Sometimes it is necessary to setup some dates without triggereing the delegate e.g. For instance, when youre initally setting up data in your viewDidLoad
    public func selectDates(dates: [NSDate], triggerSelectionDelegate: Bool = true) {
        var allIndexPathsToReload: [NSIndexPath] = []
        
        delayRunOnGlobalThread(0.0, qos: QOS_CLASS_USER_INITIATED) { 
            for date in dates {
                let components = self.calendar.components([.Year, .Month, .Day],  fromDate: date)
                let firstDayOfDate = self.calendar.dateFromComponents(components)!
                
                if !(firstDayOfDate >= self.startOfMonthCache && firstDayOfDate <= self.endOfMonthCache) {
                    // If the date is not within valid boundaries, then exit
                    continue
                }
                
                let pathFromDates = self.pathsFromDates([date])
                
                // If the date path youre searching for, doesnt exist, then return
                if pathFromDates.count < 0 {
                    continue
                }
                
                let sectionIndexPath = pathFromDates[0]
                
                
                let selectTheDate = {
                    delayRunOnMainThread(0.0) {
                        self.calendarView.selectItemAtIndexPath(sectionIndexPath, animated: false, scrollPosition: .None)
                    }
                    
                    // If triggereing is enabled, then let their delegate handle the reloading of view, else we will reload the data
                    if triggerSelectionDelegate {
                        delayRunOnMainThread(0.0) {
                            self.collectionView(self.calendarView, didSelectItemAtIndexPath: sectionIndexPath)
                        }
                    } else { // Although we do not want the delegate triggered, we still want counterpart cells to be selected
                        
                        // Because there is no triggering of the delegate, the cell will not be added to selection and it will not be reloaded. We need to do this here
                        self.addCellToSelectedSetIfUnselected(sectionIndexPath, date: date)
                        allIndexPathsToReload.append(sectionIndexPath)
                        
                        let cellState = self.cellStateFromIndexPath(sectionIndexPath, withDate: date)
                        if let aSelectedCounterPartIndexPath = self.selectCounterPartCellIndexPathIfExists(sectionIndexPath, date: date, dateOwner: cellState.dateBelongsTo) {
                            // If there was a counterpart cell then it will also need to be reloaded
                            allIndexPathsToReload.append(aSelectedCounterPartIndexPath)
                        }
                    }
                }
                
                let deSelectTheDate = { (indexPath: NSIndexPath) -> Void in
                    allIndexPathsToReload.append(indexPath)
                    delayRunOnMainThread(0.0) {
                        self.calendarView.deselectItemAtIndexPath(indexPath, animated: false)
                    }
                    if
                        self.theSelectedIndexPaths.contains(indexPath),
                        let index = self.theSelectedIndexPaths.indexOf(indexPath) {
                        
                        self.theSelectedIndexPaths.removeAtIndex(index)
                        self.theSelectedDates.removeAtIndex(index)
                    }
                    // If delegate triggering is enabled, let the delegate function handle the cell
                    if triggerSelectionDelegate {
                        delayRunOnMainThread(0.0) {
                            self.collectionView(self.calendarView, didDeselectItemAtIndexPath: indexPath)
                        }
                    } else { // Although we do not want the delegate triggered, we still want counterpart cells to be deselected
                        let cellState = self.cellStateFromIndexPath(sectionIndexPath, withDate: date)
                        if let anUnselectedCounterPartIndexPath = self.deselectCounterPartCellIndexPath(indexPath, date: date, dateOwner: cellState.dateBelongsTo) {
                            // If there was a counterpart cell then it will also need to be reloaded
                             allIndexPathsToReload.append(anUnselectedCounterPartIndexPath)
                        }
                    }
                }
                
                // Remove old selections
                if self.calendarView.allowsMultipleSelection == false { // If single selection is ON
                    for indexPath in self.theSelectedIndexPaths {
                        if indexPath != sectionIndexPath {
                            deSelectTheDate(indexPath)
                        }
                    }
                    
                    // Add new selections
                    // Must be added here. If added in delegate didSelectItemAtIndexPath
                    selectTheDate()
                } else { // If multiple selection is on. Multiple selection behaves differently to singleselection. It behaves like a toggle.
                    
                    if self.theSelectedIndexPaths.contains(sectionIndexPath) { // If this cell is already selected, then deselect it
                        deSelectTheDate(sectionIndexPath)
                    } else {
                        // Add new selections
                        // Must be added here. If added in delegate didSelectItemAtIndexPath
                        selectTheDate()
                    }
                }
            }
            
            // If triggering was false, although the selectDelegates weren't called, we do want the cell refreshed. Reload to call itemAtIndexPath
            if triggerSelectionDelegate == false {
                delayRunOnMainThread(0.0) {
                    self.reloadIndexPathsIfVisible(allIndexPathsToReload)
                }
            }
        }
    }
    
    /// Scrolls the calendar view to the next section view. It will execute a completion handler at the end of scroll animation if provided.
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToNextSegment(animateScroll: Bool = true, completionHandler:(()->Void)? = nil) {
        let page = currentSectionPage
        if page + 1 < monthInfo.count {
            let position: UICollectionViewScrollPosition = self.direction == .Horizontal ? .Left : .Top
            if let validHandler = completionHandler {
              delayedExecutionClosure.append(validHandler)
            }
            calendarView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection:page + 1), atScrollPosition: position, animated: animateScroll)
        }
    }
    /// Scrolls the calendar view to the previous section view. It will execute a completion handler at the end of scroll animation if provided.
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToPreviousSegment(animateScroll: Bool = true, completionHandler:(()->Void)? = nil) {
        let page = currentSectionPage
        if page - 1 > -1 {
            let position: UICollectionViewScrollPosition = self.direction == .Horizontal ? .Left : .Top
            if let validHandler = completionHandler {
              delayedExecutionClosure.append(validHandler)
            }
            calendarView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection:page - 1), atScrollPosition: position, animated: animateScroll)
        }
    }

    /// Scrolls the calendar view to the start of a section view containing a specified date.
    /// - Paramater date: The calendar view will scroll to a date-cell containing this date if it exists
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Paramater preferredScrollPositionIndex: Integer indicating the end scroll position on the screen. This value indicates column number for Horizontal scrolling and row number for a vertical scrolling calendar
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToDate(date: NSDate, triggerScrollToDateDelegate: Bool = true, animateScroll: Bool = true, preferredScrollPosition: UICollectionViewScrollPosition? = nil, completionHandler:(()->Void)? = nil) {
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        
        let components = calendar.components([.Year, .Month, .Day],  fromDate: date)
        let firstDayOfDate = calendar.dateFromComponents(components)!
        
        scrollInProgress = true
        delayRunOnMainThread(0.0, closure: {
            // This part should be inside the mainRunLoop
            if !(firstDayOfDate >= self.startOfMonthCache && firstDayOfDate <= self.endOfMonthCache) {
                self.scrollInProgress = false
                return
            }
            
            let retrievedPathsFromDates = self.pathsFromDates([date])
            
            if retrievedPathsFromDates.count > 0 {
                let sectionIndexPath =  self.pathsFromDates([date])[0]
                var position: UICollectionViewScrollPosition = self.direction == .Horizontal ? .Left : .Top
                if !self.pagingEnabled {
                    if let validPosition:UICollectionViewScrollPosition = preferredScrollPosition {
                        if self.direction == .Horizontal {
                            if validPosition == .Left || validPosition == .Right || validPosition == .CenteredHorizontally {
                                position = validPosition
                            } else {
                                position = .Left
                            }
                        } else {
                            if validPosition == .Top || validPosition == .Bottom || validPosition == .CenteredVertically {
                                position = validPosition
                            } else {
                                position = .Top
                            }
                        }
                    }
                }
                
                let scrollToIndexPath = {(iPath: NSIndexPath, withAnimation: Bool)-> Void in
                    if let validCompletionHandler = completionHandler { self.delayedExecutionClosure.append(validCompletionHandler) }
                     
                    // regular movement
                    self.calendarView.scrollToItemAtIndexPath(iPath, atScrollPosition: position, animated: animateScroll)
                    
                    
                    if animateScroll {
                        if let check = self.calendarOffsetIsAlreadyAtScrollPosition(forIndexPath: iPath) where check == true {
                                self.scrollViewDidEndScrollingAnimation(self.calendarView)
                                self.scrollInProgress = false
                                return
                        }
                    }
                }
                
                if self.pagingEnabled {
                    if headerViewXibs.count > 0 {
                        // If both paging and header is on, then scroll to the actual date
                        // If direction is vertical and user has a custom size that is at least the size of the collectionview. 
                        // If this check is not done, it will scroll to header, and have white space at bottom because view is smaller due to small custom user itemSize
                        if self.direction == .Vertical && (self.calendarView.collectionViewLayout as! JTAppleCalendarLayout).sizeOfSection(sectionIndexPath.section) >= self.calendarView.frame.height {
                            self.scrollToHeaderInSection(sectionIndexPath.section, triggerScrollToDateDelegate: triggerScrollToDateDelegate, withAnimation: animateScroll, completionHandler: completionHandler)
                            return
                        } else {
                            scrollToIndexPath(NSIndexPath(forItem: 0, inSection: sectionIndexPath.section), animateScroll)
                        }
                    } else {
                        // If paging is on and header is off, then scroll to the start date in section
                        scrollToIndexPath(NSIndexPath(forItem: 0, inSection: sectionIndexPath.section), animateScroll)
                    }
                } else {
                    // If paging is off, then scroll to the actual date in the section
                    scrollToIndexPath(sectionIndexPath, animateScroll)
                }
                
                // Jt101 put this into a function to reduce code between this and the scroll to header function
                delayRunOnMainThread(0.0, closure: {
                    if  !animateScroll  {
                        self.scrollViewDidEndScrollingAnimation(self.calendarView)
                        self.scrollInProgress = false
                    }
                })
            }
        })
    }
    
    /// Scrolls the calendar view to the start of a section view header. If the calendar has no headers registered, then this function does nothing
    /// - Paramater date: The calendar view will scroll to the header of a this provided date
    public func scrollToHeaderForDate(date: NSDate, triggerScrollToDateDelegate: Bool = false, withAnimation animation: Bool = false, completionHandler: (()->Void)? = nil) {
        let path = pathsFromDates([date])
        // Return if date was incalid and no path was returned
        if path.count < 1 { return }
        scrollToHeaderInSection(path[0].section, triggerScrollToDateDelegate: triggerScrollToDateDelegate, withAnimation: animation, completionHandler: completionHandler)
    }
}