# AI Agent Testing Prompt for Sree Krishna Residency Booking System

You are a professional QA tester AI agent tasked with thoroughly testing the Sree Krishna Residency booking system. Your mission is to execute comprehensive end-to-end testing across all pages, features, and functionality. Report detailed findings for each test case.

## System Under Test
- Website: Sree Krishna Residency (index.html)
- Booking System: booking.html
- Admin Panel: admin.html
- Check-in Page: checkin.html
- Check-out Page: checkout.html
- Database: Supabase (chjwvpvsxeczvwqyouiw.supabase.co)

---

## PHASE 1: DATABASE SETUP

### Task 1.1: Insert Sample Test Data
Execute the following SQL in Supabase SQL Editor to create test bookings for all room types:

```sql
-- Clear existing test bookings (keep only real data)
DELETE FROM public.bookings WHERE customer_name LIKE 'Test Guest%' OR customer_name LIKE 'Past Guest%' OR customer_name LIKE 'Cancelled Guest%';

-- 1. 2 Bed AC
INSERT INTO public.bookings (property_id, room_id, customer_name, phone, check_in, check_out, nights, price_at_booking, advance_paid, payment_status, status, source, created_at)
VALUES ('sreekrishna', 'a37f91b7-6cb5-48b9-9789-459da5d30946', 'Test Guest - 2 Bed AC', '9876543210', '2026-04-21', '2026-04-23', 2, 1800, 1800, 'fully_paid', 'active', 'direct', NOW() - INTERVAL '1 day');

-- 2. 3 Bed AC
INSERT INTO public.bookings (property_id, room_id, customer_name, phone, check_in, check_out, nights, price_at_booking, advance_paid, payment_status, status, source, created_at)
VALUES ('sreekrishna', 'bb19bbdf-dd78-447f-a331-5e85839e0358', 'Test Guest - 3 Bed AC', '9876543211', '2026-04-21', '2026-04-24', 3, 2000, 1000, 'advance_paid', 'active', 'makemytrip', NOW() - INTERVAL '2 days');

-- 3. 4 Bed AC
INSERT INTO public.bookings (property_id, room_id, customer_name, phone, check_in, check_out, nights, price_at_booking, advance_paid, payment_status, status, source, created_at)
VALUES ('sreekrishna', '252cd306-61c6-4185-ad20-7d469b352edf', 'Test Guest - 4 Bed AC Family', '9876543212', '2026-04-22', '2026-04-25', 3, 2400, 2400, 'fully_paid', 'active', 'direct', NOW() - INTERVAL '3 days');

-- 4. 2 Bed Non AC
INSERT INTO public.bookings (property_id, room_id, customer_name, phone, check_in, check_out, nights, price_at_booking, advance_paid, payment_status, status, source, created_at)
VALUES ('sreekrishna', 'ad246538-657a-48ea-8361-bf728a55f733', 'Test Guest - 2 Bed Non AC', '9876543213', '2026-04-23', '2026-04-25', 2, 1100, 500, 'advance_paid', 'active', 'booking.com', NOW() - INTERVAL '4 days');

-- 5. 3 Bed Non AC
INSERT INTO public.bookings (property_id, room_id, customer_name, phone, check_in, check_out, nights, price_at_booking, advance_paid, payment_status, status, source, created_at)
VALUES ('sreekrishna', 'c410574e-9483-4ca0-8ec2-a248cd6ccc23', 'Test Guest - 3 Bed Non AC', '9876543214', '2026-04-21', '2026-04-26', 5, 1300, 1300, 'fully_paid', 'active', 'direct', NOW() - INTERVAL '5 days');

-- 6. 4 Bed Non AC
INSERT INTO public.bookings (property_id, room_id, customer_name, phone, check_in, check_out, nights, price_at_booking, advance_paid, payment_status, status, source, created_at)
VALUES ('sreekrishna', 'a480823a-a86a-4c01-bdc7-6b325769b677', 'Test Guest - 4 Bed Non AC', '9876543215', '2026-04-24', '2026-04-27', 3, 1400, 700, 'advance_paid', 'active', 'makemytrip', NOW() - INTERVAL '6 days');

-- 7. 8 Bed Non AC Family
INSERT INTO public.bookings (property_id, room_id, customer_name, phone, check_in, check_out, nights, price_at_booking, advance_paid, payment_status, status, source, created_at)
VALUES ('sreekrishna', '83c6e05b-4a83-4785-8f99-993d766f6b21', 'Test Guest - 8 Bed Non AC Family', '9876543216', '2026-04-25', '2026-04-30', 5, 2400, 2400, 'fully_paid', 'active', 'direct', NOW() - INTERVAL '7 days');

-- 8. Completed Booking - 2 Bed AC
INSERT INTO public.bookings (property_id, room_id, customer_name, phone, check_in, check_out, nights, price_at_booking, advance_paid, payment_status, status, source, created_at)
VALUES ('sreekrishna', 'a37f91b7-6cb5-48b9-9789-459da5d30946', 'Past Guest - 2 Bed AC', '9876543217', '2026-04-15', '2026-04-18', 3, 1800, 1800, 'fully_paid', 'completed', 'direct', NOW() - INTERVAL '10 days');

-- 9. Cancelled Booking - 3 Bed AC
INSERT INTO public.bookings (property_id, room_id, customer_name, phone, check_in, check_out, nights, price_at_booking, advance_paid, payment_status, status, source, created_at)
VALUES ('sreekrishna', 'bb19bbdf-dd78-447f-a331-5e85839e0358', 'Cancelled Guest - 3 Bed AC', '9876543218', '2026-04-20', '2026-04-22', 2, 2000, 0, 'unpaid', 'cancelled', 'direct', NOW() - INTERVAL '8 days');
```

After executing, verify:
```sql
SELECT customer_name, check_in, check_out, status, source FROM public.bookings WHERE customer_name LIKE 'Test Guest%' OR customer_name LIKE 'Past Guest%' OR customer_name LIKE 'Cancelled Guest%' ORDER BY created_at DESC;
```

---

## PHASE 2: FRONTEND TESTING

### Task 2.1: Test Website (index.html)
Navigate to the website and test:
- [ ] Homepage loads without errors
- [ ] Logo displays correctly
- [ ] Navigation links work (scroll to sections)
- [ ] "Get Directions" button opens Google Maps (URL: maps.app.goo.gl/MXrVRaLwrrVDq2yd8)
- [ ] "Send Enquiry (WhatsApp)" opens WhatsApp with pre-filled message
- [ ] "Call Now" button initiates phone call
- [ ] All room cards display with correct images and prices
- [ ] "Book Now" buttons redirect to booking page with correct room_id

### Task 2.2: Test Booking Page (booking.html)
For each room type, test:
- [ ] booking.html?room_id=2bed-ac loads "2 Bed AC" - Verify room name, price (₹1800)
- [ ] booking.html?room_id=3bed-ac loads "3 Bed AC" - Verify room name, price (₹2000)
- [ ] booking.html?room_id=4bed-ac loads "4 Bed AC" - Verify room name, price (₹2400)
- [ ] booking.html?room_id=2bed-nonac loads "2 Bed Non AC" - Verify room name, price (₹1100)
- [ ] booking.html?room_id=3bed-nonac loads "3 Bed Non AC" - Verify room name, price (₹1300)
- [ ] booking.html?room_id=4bed-nonac loads "4 Bed Non AC" - Verify room name, price (₹1400)
- [ ] booking.html?room_id=8bed-dorm loads "8 Bed Non AC" - Verify room name, price (₹2400)

Test booking form submission:
- [ ] Select valid dates (check-in before check-out)
- [ ] Enter valid name (minimum 3 characters)
- [ ] Enter valid phone (10 digits)
- [ ] Submit booking successfully
- [ ] Verify booking appears in database with correct room_id

### Task 2.3: Test Check-in Page (checkin.html)
- [ ] Page loads without errors
- [ ] Logo displays correctly (images/logo.webp)
- [ ] Check-in time shows "03:00 PM"
- [ ] Check-out time shows "02:00 PM"
- [ ] WiFi network shows "SREEKRISHNA"
- [ ] WiFi password shows "sreekrishna@321"
- [ ] Map preview loads (Google Maps embed)
- [ ] "Get Directions" button works

### Task 2.4: Test Check-out Page (checkout.html)
- [ ] Page loads without errors
- [ ] Thank you message displays
- [ ] Check-out time shows "02:00 PM"
- [ ] Star rating renders (1-5 stars)
- [ ] Clicking 4+ stars redirects to Google Maps review
- [ ] Clicking below 4 stars shows thank you message
- [ ] "Maybe Later" button shows final thank you

---

## PHASE 3: ADMIN PANEL TESTING

### Task 3.1: Test Login & Authentication
- [ ] Login form accepts credentials
- [ ] Session persists on page refresh
- [ ] Logout works correctly

### Task 3.2: Test Bookings Tab
Navigate to admin panel and test:

#### Booking List Display
- [ ] All 9 test bookings appear
- [ ] Each booking shows correct room name (NOT all "2 Bed AC")
- [ ] Search by guest name works
- [ ] Search by phone number works
- [ ] Filter by "All" status shows all bookings
- [ ] Filter by "Active" shows only active bookings
- [ ] Filter by "Completed" shows completed bookings
- [ ] Filter by "Cancelled" shows cancelled bookings

#### CRITICAL: Verify Room Name Mapping
For each booking card, verify the room name displayed:

| Booking | Should Show | Not |
|---------|------------|-----|
| Test Guest - 2 Bed AC | 2 Bed AC | ❌ Wrong room |
| Test Guest - 3 Bed AC | 3 Bed AC | ❌ Wrong room |
| Test Guest - 4 Bed AC Family | 4 Bed AC | ❌ Wrong room |
| Test Guest - 2 Bed Non AC | 2 Bed Non AC | ❌ Wrong room |
| Test Guest - 3 Bed Non AC | 3 Bed Non AC | ❌ Wrong room |
| Test Guest - 4 Bed Non AC | 4 Bed Non AC | ❌ Wrong room |
| Test Guest - 8 Bed Non AC Family | 8 Bed Non AC | ❌ Wrong room |
| Past Guest - 2 Bed AC | Completed | ❌ Wrong status |
| Cancelled Guest - 3 Bed AC | Cancelled | ❌ Wrong status |

#### Booking Card Actions
- [ ] "View Details" opens booking details modal
- [ ] "Payment" opens payment recording modal
- [ ] "WhatsApp" opens WhatsApp with message
- [ ] "Check-in" opens WhatsApp with check-in link
- [ ] "Check-out" opens WhatsApp with check-out link

#### Booking Details Modal Verification
For "Test Guest - 3 Bed AC", verify:
- [ ] Room name shows "3 Bed AC" (NOT "2 Bed AC")
- [ ] Check-in date is correct
- [ ] Check-out date is correct  
- [ ] Nights is correct (3)
- [ ] Price per night is correct (₹2000)
- [ ] Total amount calculates correctly (₹2000 × 3 = ₹6000)
- [ ] Advance paid shows ₹1000
- [ ] Balance due shows ₹5000
- [ ] Payment status shows "Advance Paid"
- [ ] Source shows "makemytrip"

### Task 3.3: Test Payment Modal
- [ ] Opens with correct booking amount
- [ ] Discount field calculates correctly
- [ ] "Record Payment" saves to database
- [ ] Payment status updates correctly
- [ ] Balance due becomes ₹0 after full payment

### Task 3.4: Test Status Actions
- [ ] "Check-in" button changes status to "checked_in"
- [ ] "Check-out" button changes status to "completed"
- [ ] "Cancel" button changes status to "cancelled"

### Task 3.5: Test Revenue Tab
- [ ] Date filters work (From/To)
- [ ] "Calculate" button generates report
- [ ] Total Revenue KPI displays
- [ ] Today's Revenue KPI displays
- [ ] This Month KPI displays
- [ ] Advance Received KPI displays
- [ ] Pending Balance KPI displays
- [ ] Avg per Booking KPI displays
- [ ] Bar chart renders correctly
- [ ] Pie chart renders correctly
- [ ] Detailed breakdown table shows all room types

### Task 3.6: Test Analytics Tab
- [ ] "Last 7 days" filter works
- [ ] "Last 30 days" filter works
- [ ] "Last 90 days" filter works
- [ ] "Last 1 Year" filter works
- [ ] All KPI cards display correctly

---

## PHASE 4: EXPORT TESTING

### Task 4.1: Test Excel Export
- [ ] Navigate to Settings → Export
- [ ] Click "Export Monthly Report"
- [ ] Excel file downloads
- [ ] Excel file opens without errors
- [ ] Verify dates are in correct format (DD-MM-YYYY)
- [ ] Verify numbers display correctly (not scientific notation)
- [ ] Verify all columns present:
  - Booking ID
  - Guest Name
  - Phone
  - Room
  - AC/Non-AC
  - Check-in
  - Check-out
  - Nights
  - Price/Night
  - Total Amount
  - Advance Paid
  - Balance Due
  - Payment Status
  - Status
  - Source

---

## PHASE 5: REPORTING

Create a detailed test report with:

### Summary
- Total tests run: ___
- Passed: ___
- Failed: ___
- Pass rate: ___

### Critical Issues Found
1. [Issue description]
2. [Issue description]
3. [Issue description]

### Screenshots
Capture screenshots of any failures or issues.

### Recommendations
- [Recommendation 1]
- [Recommendation 2]

---

## MANDATORY CHECKS - DO NOT SKIP

1. **Room Name Bug Check**: Verify ALL 7 room type bookings show DIFFERENT room names in admin panel - NOT all showing "2 Bed AC"
2. **Excel Date Format**: Verify dates are DD-MM-YYYY not MM-DD-YYYY or other formats
3. **Payment Calculations**: Verify advance + balance = total amount
4. **Check-in Link**: Verify WhatsApp message contains correct check-in.html URL after recent fix

---

Execute each phase sequentially. Document all findings. Report any failures immediately with screenshot evidence.