# Sree Krishna Residency - Complete Testing Checklist

## 📱 Website (index.html)

### Header & Navigation
- [ ] Logo displays correctly
- [ ] Navigation links work (Rooms, Amenities, Gallery, Dining, Location)
- [ ] "Get Directions" button opens Google Maps
- [ ] "Send Enquiry (WhatsApp)" opens WhatsApp with message
- [ ] "Call Now" button initiates call
- [ ] Mobile menu toggles properly

### Room Section
- [ ] All room cards display with correct images
- [ ] Room prices show correctly
- [ ] "View Details" buttons work
- [ ] "Book Now" buttons redirect to booking page with correct room

### Booking Form
- [ ] Room type dropdown shows all options
- [ ] Date picker works (check-in/check-out)
- [ ] Form validation works (required fields)
- [ ] Submit booking creates record in database

---

## 📝 Booking Page (booking.html)

### Room Selection
- [ ] URL parameter `?room_id=2bed-ac` loads correct room
- [ ] URL parameter `?room_id=3bed-ac` loads correct room
- [ ] Room name displays correctly
- [ ] Price shows correctly

### Booking Form
- [ ] Check-in date picker works
- [ ] Check-out date picker works
- [ ] Guest name input validates
- [ ] Phone number validates (10 digits)
- [ ] Form submission creates booking
- [ ] Success message shows after booking
- [ ] Honeypot blocks spam submissions

---

## 🛎️ Check-in Page (checkin.html)

- [ ] Page loads without errors
- [ ] Logo displays correctly
- [ ] Welcome message shows
- [ ] Check-in time (03:00 PM) displays
- [ ] Check-out time (02:00 PM) displays
- [ ] WiFi network name shows (SREEKRISHNA)
- [ ] WiFi password shows (sreekrishna@321)
- [ ] Directions list displays all 4 points
- [ ] Map preview loads correctly
- [ ] "Get Directions" button opens Google Maps
- [ ] Contact info shows (phone, location)
- [ ] Responsive on mobile

---

## 🏁 Check-out Page (checkout.html)

- [ ] Page loads without errors
- [ ] Logo displays correctly
- [ ] Thank you message shows
- [ ] Check-out time (02:00 PM) displays
- [ ] Departure checklist shows 4 items
- [ ] Star rating displays (1-5 stars)
- [ ] Clicking 4+ stars redirects to Google Maps review
- [ ] Clicking below 4 stars shows thank you message
- [ ] "Maybe Later" button works
- [ ] Responsive on mobile

---

## ⚙️ Admin Panel (admin.html)

### Login & Authentication
- [ ] Login form accepts credentials
- [ ] Session persists on refresh
- [ ] Logout works
- [ ] Unauthorized access blocked

### Sidebar Navigation
- [ ] Overview tab loads
- [ ] Bookings tab loads
- [ ] Shift Notes tab loads
- [ ] Availability tab loads
- [ ] Calendar tab loads
- [ ] Revenue tab loads
- [ ] Analytics tab loads
- [ ] Rooms tab loads
- [ ] Settings tab loads
- [ ] Help tab loads
- [ ] Sidebar collapses/expands
- [ ] Mobile hamburger menu works

### Overview Dashboard
- [ ] Total bookings count shows
- [ ] Active bookings count shows
- [ ] Today's check-ins count shows
- [ ] Today's check-outs count shows
- [ ] Available rooms count shows
- [ ] Occupancy percentage shows
- [ ] This month revenue shows
- [ ] Quick Revenue button works
- [ ] Quick Calendar button works

### Bookings Tab

#### Booking List
- [ ] All bookings display
- [ ] Search by name works
- [ ] Search by phone works
- [ ] Filter by status (All) works
- [ ] Filter by status (Active) works
- [ ] Filter by status (Completed) works
- [ ] Filter by status (Cancelled) works
- [ ] Pagination works
- [ ] Booking cards show correct room name

#### Booking Card Actions
- [ ] Guest name clickable (opens history)
- [ ] "View Details" button opens modal
- [ ] "Payment" button opens payment modal
- [ ] "WhatsApp" button opens WhatsApp with message
- [ ] "Check-in" button sends check-in link
- [ ] "Check-out" button sends check-out link

#### Booking Details Modal
- [ ] Shows guest name
- [ ] Shows phone number
- [ ] Shows room type (CORRECT - not all "2 Bed AC")
- [ ] Shows check-in date
- [ ] Shows check-out date
- [ ] Shows number of nights
- [ ] Shows price per night
- [ ] Shows total amount
- [ ] Shows advance paid
- [ ] Shows balance due
- [ ] Shows payment status
- [ ] Shows booking source
- [ ] Shows special requests
- [ ] Shows created date/time

#### Payment Modal
- [ ] Opens with correct amount
- [ ] Discount field works
- [ ] Cash given field calculates correctly
- [ ] Payment type dropdown works
- [ ] Payment method dropdown works
- [ ] Notes field works
- [ ] "Record Payment" saves correctly
- [ ] Payment updates booking status

#### Status Actions
- [ ] "Check-in" button marks guest as checked in
- [ ] "Check-out" button marks guest as checked out
- [ ] "Cancel" button shows cancellation reason
- [ ] Cancellation saves correctly

### New Bookings Section
- [ ] Unseen bookings show with badge
- [ ] "Mark Seen" button works
- [ ] "Mark All Seen" button works
- [ ] Clicking notification scrolls to section

### Availability Tab
- [ ] Room list displays correctly
- [ ] AC rooms section shows
- [ ] Non-AC rooms section shows
- [ ] Available rooms count is accurate
- [ ] Occupancy percentage is accurate

### Calendar Tab
- [ ] Calendar displays 14 days
- [ ] Room rows display correctly
- [ ] Booked dates highlighted
- [ ] Available dates show green
- [ ] Hover shows booking details

### Revenue Tab
- [ ] Date filter (From) works
- [ ] Date filter (To) works
- [ ] "Calculate" button generates report
- [ ] Total Revenue KPI displays
- [ ] Today's Revenue KPI displays
- [ ] This Month KPI displays
- [ ] Advance Received KPI displays
- [ ] Pending Balance KPI displays
- [ ] Avg per Booking KPI displays
- [ ] Bar chart renders correctly
- [ ] Pie chart renders correctly
- [ ] Detailed table shows breakdown

### Analytics Tab
- [ ] "Last 7 days" filter works
- [ ] "Last 30 days" filter works
- [ ] "Last 90 days" filter works
- [ ] "Last 1 Year" filter works
- [ ] "Refresh" button works
- [ ] Total Bookings KPI displays
- [ ] Confirmed KPI displays
- [ ] Total Guests KPI displays
- [ ] Repeat Guest Rate KPI displays
- [ ] Cancelled KPI displays
- [ ] Cancellation Rate KPI displays
- [ ] Booking Trend chart shows
- [ ] Booking Sources shows
- [ ] Repeat Guests shows
- [ ] Room Popularity shows

### Shift Notes Tab
- [ ] Compose note textarea works
- [ ] Priority dropdown works (Normal, Urgent, Low)
- [ ] "Post Note" button saves
- [ ] Notes list displays
- [ ] Filter "All" works
- [ ] Filter "Unresolved" works
- [ ] Filter "Urgent" works

### Audit Log Tab
- [ ] All actions filter works
- [ ] "Booking Cancelled" filter works
- [ ] "Booking Completed" filter works
- [ ] "Room Updated" filter works
- [ ] "Payment Recorded" filter works
- [ ] Date filter works

### Rooms Tab
- [ ] AC rooms section displays
- [ ] Non-AC rooms section displays
- [ ] Each room shows name
- [ ] Each room shows price
- [ ] Each room shows available rooms
- [ ] Edit price works (manager only)
- [ ] Update availability works
- [ ] Save button updates database

### Settings Tab

#### Appearance
- [ ] Theme toggle (Dark/Light) works
- [ ] Sidebar toggle works
- [ ] Default tab selection works
- [ ] Items per page works
- [ ] Date format works
- [ ] Time format works
- [ ] Auto-refresh toggle works

#### Export
- [ ] "Export Bookings CSV" downloads file
- [ ] "Export Revenue CSV" downloads file
- [ ] "Export Monthly Report" downloads Excel file
- [ ] Excel file opens without errors
- [ ] Excel dates are correct format
- [ ] Excel numbers display correctly
- [ ] Excel has all columns

#### Backup
- [ ] "Download Backup" works
- [ ] Backup JSON is valid

### Help Tab
- [ ] Help content displays
- [ ] Version number shows

---

## 🔗 WhatsApp Integration

### Admin Panel
- [ ] New booking notification sends
- [ ] Booking details message is correct
- [ ] Phone number formats correctly (+91...)
- [ ] Message opens in WhatsApp

### Check-in Link
- [ ] Check-in button sends WhatsApp message
- [ ] Message includes guest name
- [ ] Message includes check-in date
- [ ] Message includes check-out date
- [ ] Message includes check-in URL
- [ ] Link opens correct page

### Check-out Link
- [ ] Check-out button sends WhatsApp message
- [ ] Message includes guest name
- [ ] Message includes check-out URL
- [ ] Link opens correct page

---

## 🗄️ Database

- [ ] Bookings table stores all fields
- [ ] Rooms table stores all fields
- [ ] Payments table records payments
- [ ] Shift notes saves correctly
- [ ] Audit log tracks actions

---

## 📊 Data Accuracy

- [ ] Room names match (not all "2 Bed AC")
- [ ] Prices are correct
- [ ] Calculations are accurate (nights × price)
- [ ] Advance paid subtracts correctly
- [ ] Balance due calculates correctly
- [ ] Revenue totals are accurate
- [ ] Occupancy percentage is correct

---

## 🐛 Bug Testing

### Known Issues - Verify Fixed
- [ ] Room booking saves correct room_id (not all 2 Bed AC)
- [ ] Excel dates don't glitch
- [ ] Excel numbers display properly

### Error Handling
- [ ] No console errors on page load
- [ ] Network errors show friendly message
- [ ] Failed requests don't break UI

---

## 📱 Mobile Responsive

- [ ] index.html works on mobile
- [ ] booking.html works on mobile
- [ ] checkin.html works on mobile
- [ ] checkout.html works on mobile
- [ ] admin.html works on mobile
- [ ] All buttons are tappable
- [ ] Text is readable
- [ ] No horizontal scroll

---

## 🧪 Sample Bookings Test

I've created sample bookings in the database. Run the SQL file `TEST_SAMPLE_BOOKINGS.sql` in Supabase SQL Editor to insert them, then verify:

### Bookings to Check in Admin Panel:

| # | Guest Name | Room Type | Expected |
|---|------------|-----------|----------|
| 1 | Test Guest - 2 Bed AC | 2 Bed AC | ✅ Should show "2 Bed AC" |
| 2 | Test Guest - 3 Bed AC | 3 Bed AC | ✅ Should show "3 Bed AC" |
| 3 | Test Guest - 4 Bed AC Family | 4 Bed AC | ✅ Should show "4 Bed AC" |
| 4 | Test Guest - 2 Bed Non AC | 2 Bed Non AC | ✅ Should show "2 Bed Non AC" |
| 5 | Test Guest - 3 Bed Non AC | 3 Bed Non AC | ✅ Should show "3 Bed Non AC" |
| 6 | Test Guest - 4 Bed Non AC | 4 Bed Non AC | ✅ Should show "4 Bed Non AC" |
| 7 | Test Guest - 8 Bed Non AC Family | 8 Bed Non AC | ✅ Should show "8 Bed Non AC" |
| 8 | Past Guest - 2 Bed AC | 2 Bed AC | ✅ Should show "Completed" status |
| 9 | Cancelled Guest - 3 Bed AC | 3 Bed AC | ✅ Should show "Cancelled" status |

### Test Each Room:

- [ ] 2 Bed AC booking shows correct room name (NOT "2 Bed AC" for all!)
- [ ] 3 Bed AC booking shows correct room name
- [ ] 4 Bed AC booking shows correct room name
- [ ] 2 Bed Non AC booking shows correct room name
- [ ] 3 Bed Non AC booking shows correct room name
- [ ] 4 Bed Non AC booking shows correct room name
- [ ] 8 Bed Non AC booking shows correct room name
- [ ] Completed booking shows "Completed" status
- [ ] Cancelled booking shows "Cancelled" status
- [ ] Advance amounts display correctly
- [ ] Balance due calculates correctly

### To Run SQL:
1. Go to Supabase Dashboard → SQL Editor
2. Copy all SQL from `TEST_SAMPLE_BOOKINGS.sql`
3. Run the query
4. Check Admin Panel Bookings tab

---

## ✅ Final Sign-off

| Item | Tested By | Date | Status |
|------|-----------|------|--------|
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |

---

**Tested by:** _________________
**Date:** _________________
**Total Pass:** _____ / _____
**Pass Rate:** _____%
