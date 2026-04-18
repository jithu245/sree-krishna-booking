# How to Add Rooms in Sree Krishna Residency Admin Panel

## Room Setup

The rooms in the database need to be named exactly to match the booking system:

```sql
-- Clear existing rooms and add new ones
DELETE FROM rooms WHERE property_id = 'sreekrishna';

-- Add rooms with exact names for booking system to find them
INSERT INTO rooms (property_id, name, price, total_rooms, description)
VALUES 
('sreekrishna', '2 Bed Room', 1800, 35, 'Spacious 2 bed room with AC or Non-AC options'),
('sreekrishna', '3 Bed Room', 2000, 27, 'Comfortable 3 bed room with AC or Non-AC options'),
('sreekrishna', '4 Bed Room', 2400, 20, 'Large 4 bed room with AC or Non-AC options'),
('sreekrishna', '8 Bed Dormitory', 2400, 5, 'Shared dormitory with 8 beds - Non-AC only');
```

## How Booking Works

### From index.html (Room Cards):
- Click "Book AC" or "Book Non-AC" buttons on room cards
- This sends user to `booking.html?room_id=2bed-ac` (or similar)
- The system maps these IDs to room names in the database

### Room ID Mappings:
| URL Parameter | Room Name | Type | Price |
|--------------|-----------|------|-------|
| ?room_id=2bed-ac | 2 Bed Room | AC | ₹1,800 |
| ?room_id=2bed-nonac | 2 Bed Room | Non-AC | ₹1,100 |
| ?room_id=3bed-ac | 3 Bed Room | AC | ₹2,000 |
| ?room_id=3bed-nonac | 3 Bed Room | Non-AC | ₹1,300 |
| ?room_id=4bed-ac | 4 Bed Room | AC | ₹2,400 |
| ?room_id=4bed-nonac | 4 Bed Room | Non-AC | ₹1,400 |
| ?room_id=8bed-dorm | 8 Bed Dormitory | Non-AC | ₹2,400 |

### Booking Flow:
1. User clicks "Book AC" on a room card
2. Goes to `booking.html?room_id=2bed-ac`
3. System finds "2 Bed Room" in database
4. Displays price as ₹1,800 (AC rate)
5. When confirmed, booking is saved in admin panel

## Checking Bookings in Admin Panel

1. Go to `admin.html`
2. Login with admin credentials
3. View "All Bookings" section
4. Bookings will show:
   - Customer name, phone
   - Room type (e.g., "2 Bed Room (AC)")
   - Check-in/Check-out dates
   - Status (active/checked-out/cancelled)

## Troubleshooting

If booking doesn't work:
1. Make sure rooms exist in database (run SQL above)
2. Check room names exactly match (case-sensitive)
3. Clear browser cache and try again