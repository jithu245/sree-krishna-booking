-- Sample Bookings for Testing - Run this in Supabase SQL Editor
-- This creates test bookings for ALL room types to verify they're saved correctly

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

SELECT * FROM public.bookings ORDER BY created_at DESC LIMIT 20;
