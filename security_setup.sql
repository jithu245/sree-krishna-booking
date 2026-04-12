-- ============================================================
-- SUPABASE SECURITY SETUP — Sree Krishna Residency
-- RLS Policies, Role-Based Access, Atomic Booking RPC
-- Rate Limiting, Indexes, Foreign Keys, Price-at-Booking
-- ============================================================

-- 1. ENABLE ROW LEVEL SECURITY
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS property_id TEXT DEFAULT 'sreekrishna';
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS property_id TEXT DEFAULT 'sreekrishna';
ALTER TABLE booking_rate_limits ADD COLUMN IF NOT EXISTS property_id TEXT DEFAULT 'sreekrishna';
ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS property_id TEXT DEFAULT 'sreekrishna';

ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;

-- 2. CREATE ROLE ENUM TYPE (if not exists)
-- Note: Roles are stored in auth.users.user_metadata->>'role'
-- Valid roles: 'manager', 'receptionist'

-- 3. BOOKINGS TABLE — RLS POLICIES

-- INSERT: Anyone (public) can create a booking
DROP POLICY IF EXISTS "allow_public_booking_insert" ON bookings;
CREATE POLICY "allow_public_booking_insert"
  ON bookings FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- SELECT: Only authenticated staff can read bookings
DROP POLICY IF EXISTS "allow_staff_booking_select" ON bookings;
CREATE POLICY "allow_staff_booking_select"
  ON bookings FOR SELECT
  TO authenticated
  USING (
    auth.jwt() ->> 'role' IN ('manager', 'receptionist')
    AND auth.jwt() -> 'user_metadata' ->> 'property_id' = property_id
  );

-- UPDATE: Only authenticated staff can update bookings
DROP POLICY IF EXISTS "allow_staff_booking_update" ON bookings;
CREATE POLICY "allow_staff_booking_update"
  ON bookings FOR UPDATE
  TO authenticated
  USING (
    auth.jwt() ->> 'role' IN ('manager', 'receptionist')
    AND auth.jwt() -> 'user_metadata' ->> 'property_id' = property_id
  )
  WITH CHECK (
    auth.jwt() ->> 'role' IN ('manager', 'receptionist')
    AND auth.jwt() -> 'user_metadata' ->> 'property_id' = property_id
  );

-- DELETE: Only managers can delete bookings (if needed)
DROP POLICY IF EXISTS "allow_manager_booking_delete" ON bookings;
CREATE POLICY "allow_manager_booking_delete"
  ON bookings FOR DELETE
  TO authenticated
  USING (
    auth.jwt() ->> 'role' = 'manager'
    AND auth.jwt() -> 'user_metadata' ->> 'property_id' = property_id
  );

-- 4. ROOMS TABLE — RLS POLICIES

-- SELECT: Anyone (public) can read rooms (needed for booking page)
DROP POLICY IF EXISTS "allow_public_room_select" ON rooms;
CREATE POLICY "allow_public_room_select"
  ON rooms FOR SELECT
  TO anon, authenticated
  USING (true);

-- UPDATE: Only managers can update rooms
DROP POLICY IF EXISTS "allow_manager_room_update" ON rooms;
CREATE POLICY "allow_manager_room_update"
  ON rooms FOR UPDATE
  TO authenticated
  USING (
    auth.jwt() ->> 'role' = 'manager'
    AND auth.jwt() -> 'user_metadata' ->> 'property_id' = property_id
  )
  WITH CHECK (
    auth.jwt() ->> 'role' = 'manager'
    AND auth.jwt() -> 'user_metadata' ->> 'property_id' = property_id
  );

-- INSERT: Only managers can create rooms
DROP POLICY IF EXISTS "allow_manager_room_insert" ON rooms;
CREATE POLICY "allow_manager_room_insert"
  ON rooms FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.jwt() ->> 'role' = 'manager'
    AND auth.jwt() -> 'user_metadata' ->> 'property_id' = property_id
  );

-- DELETE: Only managers can delete rooms
DROP POLICY IF EXISTS "allow_manager_room_delete" ON rooms;
CREATE POLICY "allow_manager_room_delete"
  ON rooms FOR DELETE
  TO authenticated
  USING (
    auth.jwt() ->> 'role' = 'manager'
    AND auth.jwt() -> 'user_metadata' ->> 'property_id' = property_id
  );

-- 5. RATE LIMITING TABLE
CREATE TABLE IF NOT EXISTS booking_rate_limits (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  identifier TEXT NOT NULL,
  attempt_count INTEGER DEFAULT 1,
  last_attempt TIMESTAMPTZ DEFAULT NOW(),
  blocked_until TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rate_limits_identifier ON booking_rate_limits(identifier);
CREATE INDEX IF NOT EXISTS idx_rate_limits_blocked ON booking_rate_limits(blocked_until);

ALTER TABLE booking_rate_limits ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_staff_rate_limits_select" ON booking_rate_limits;
CREATE POLICY "allow_staff_rate_limits_select"
  ON booking_rate_limits FOR SELECT
  TO authenticated
  USING (
    auth.jwt() ->> 'role' IN ('manager', 'receptionist')
    AND auth.jwt() -> 'user_metadata' ->> 'property_id' = property_id
  );

DROP POLICY IF EXISTS "allow_staff_rate_limits_all" ON booking_rate_limits;
CREATE POLICY "allow_staff_rate_limits_all"
  ON booking_rate_limits FOR ALL
  TO authenticated
  USING (
    auth.jwt() ->> 'role' IN ('manager', 'receptionist')
    AND auth.jwt() -> 'user_metadata' ->> 'property_id' = property_id
  );

-- 6. RATE LIMIT CHECK FUNCTION
DROP FUNCTION IF EXISTS check_rate_limit(TEXT);
CREATE OR REPLACE FUNCTION check_rate_limit(p_identifier TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_record booking_rate_limits%ROWTYPE;
  v_now TIMESTAMPTZ := NOW();
BEGIN
  SELECT * INTO v_record
  FROM booking_rate_limits
  WHERE identifier = p_identifier
  AND blocked_until > v_now
  LIMIT 1;

  IF FOUND THEN
    RETURN jsonb_build_object(
      'allowed', false,
      'retry_after', EXTRACT(EPOCH FROM (v_record.blocked_until - v_now))::INTEGER
    );
  END IF;

  SELECT * INTO v_record
  FROM booking_rate_limits
  WHERE identifier = p_identifier
  AND last_attempt > v_now - INTERVAL '60 seconds'
  ORDER BY last_attempt DESC
  LIMIT 1;

  IF FOUND AND v_record.attempt_count >= 3 THEN
    UPDATE booking_rate_limits
    SET blocked_until = v_now + INTERVAL '5 minutes',
        attempt_count = v_record.attempt_count + 1
    WHERE id = v_record.id;

    RETURN jsonb_build_object('allowed', false, 'retry_after', 300);
  END IF;

  IF FOUND THEN
    UPDATE booking_rate_limits
    SET attempt_count = attempt_count + 1,
        last_attempt = v_now
    WHERE id = v_record.id;
  ELSE
    INSERT INTO booking_rate_limits (identifier, attempt_count, last_attempt)
    VALUES (p_identifier, 1, v_now);
  END IF;

  RETURN jsonb_build_object('allowed', true);
END;
$$;

-- 7. ATOMIC BOOKING CREATION — SECURE RPC FUNCTION
-- Drop old 5-argument signature to prevent overloading
DROP FUNCTION IF EXISTS create_booking_safe(UUID, DATE, DATE, TEXT, TEXT);
-- Drop the new one if we are replacing it
DROP FUNCTION IF EXISTS create_booking_safe(TEXT, UUID, DATE, DATE, TEXT, TEXT);

CREATE OR REPLACE FUNCTION create_booking_safe(
  p_property_id TEXT,
  p_room_id UUID,
  p_check_in DATE,
  p_check_out DATE,
  p_customer_name TEXT,
  p_phone TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_total_rooms INTEGER;
  v_booked_count INTEGER;
  v_available INTEGER;
  v_new_booking_id UUID;
  v_result JSONB;
  v_rate_check JSONB;
  v_room_price NUMERIC;
  v_nights INTEGER;
BEGIN
  -- Validate inputs
  IF p_room_id IS NULL OR p_room_id = '00000000-0000-0000-0000-000000000000' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invalid room');
  END IF;

  IF p_check_in IS NULL OR p_check_out IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Check-in and check-out dates are required');
  END IF;

  IF p_check_in >= p_check_out THEN
    RETURN jsonb_build_object('success', false, 'error', 'Check-out must be after check-in');
  END IF;

  IF p_check_in < CURRENT_DATE THEN
    RETURN jsonb_build_object('success', false, 'error', 'Check-in date cannot be in the past');
  END IF;

  IF p_customer_name IS NULL OR length(trim(p_customer_name)) < 2 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Valid customer name is required');
  END IF;

  IF p_phone IS NULL OR length(regexp_replace(p_phone, '[^0-9]', '', 'g')) != 10 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Valid 10-digit phone number is required');
  END IF;

  -- RATE LIMIT CHECK (C2+C4 fix: was never called before)
  v_rate_check := check_rate_limit(regexp_replace(p_phone, '[^0-9]', '', 'g'));
  IF (v_rate_check ->> 'allowed')::BOOLEAN = false THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Too many booking attempts. Please wait ' || (v_rate_check ->> 'retry_after') || ' seconds and try again.'
    );
  END IF;

  -- Lock the room row to prevent concurrent booking races
  SELECT total_rooms, price INTO v_total_rooms, v_room_price
  FROM rooms
  WHERE id = p_room_id
  FOR UPDATE;

  IF v_total_rooms IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Room not found');
  END IF;

  -- Count overlapping active bookings
  SELECT COUNT(*) INTO v_booked_count
  FROM bookings
  WHERE room_id = p_room_id
    AND status = 'active'
    AND check_in < p_check_out
    AND check_out > p_check_in;

  v_available := v_total_rooms - v_booked_count;

  IF v_available <= 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'No rooms available for selected dates');
  END IF;

  -- Calculate nights and store price at booking time (H6 fix)
  v_nights := (p_check_out - p_check_in);

  -- Atomic insert within the locked transaction
  INSERT INTO bookings (
    room_id,
    check_in,
    check_out,
    customer_name,
    phone,
    status,
    created_at,
    price_at_booking,
    nights,
    property_id
  ) VALUES (
    p_room_id,
    p_check_in,
    p_check_out,
    trim(p_customer_name),
    regexp_replace(p_phone, '[^0-9+]', '', 'g'),
    'active',
    NOW(),
    v_room_price,
    v_nights,
    COALESCE(p_property_id, 'sreekrishna')
  )
  RETURNING id INTO v_new_booking_id;

  v_result := jsonb_build_object(
    'success', true,
    'booking_id', v_new_booking_id,
    'message', 'Booking confirmed successfully'
  );

  RETURN v_result;
END;
$$;

-- 8. ADD price_at_booking AND nights COLUMNS TO BOOKINGS (H6 fix)
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS price_at_booking NUMERIC;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS nights INTEGER;

-- 8c. ADD is_seen COLUMN FOR UNCHECKED BOOKINGS TRACKING
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS is_seen BOOLEAN DEFAULT FALSE;

-- Backfill existing bookings with current data
UPDATE bookings b
SET price_at_booking = r.price,
    nights = (b.check_out - b.check_in)
FROM rooms r
WHERE b.room_id = r.id
  AND (b.price_at_booking IS NULL OR b.nights IS NULL);

-- Mark all existing bookings as seen (they were already handled before this feature)
UPDATE bookings SET is_seen = TRUE WHERE is_seen IS NULL OR is_seen = FALSE;

-- 8a. FORCE created_at TO TIMESTAMPTZ (stores UTC, converts in UI)
ALTER TABLE bookings
ALTER COLUMN created_at TYPE timestamptz
USING created_at AT TIME ZONE 'UTC';

-- 8b. ENSURE created_at DEFAULTS TO CURRENT UTC TIME
ALTER TABLE bookings
ALTER COLUMN created_at SET DEFAULT now();

-- 9. ADD FOREIGN KEY CONSTRAINT (H4 fix)
ALTER TABLE bookings DROP CONSTRAINT IF EXISTS fk_bookings_room;
ALTER TABLE bookings ADD CONSTRAINT fk_bookings_room
  FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE RESTRICT;

-- 10. ADD DATABASE INDEXES (H1 fix)
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_room_id ON bookings(room_id);
CREATE INDEX IF NOT EXISTS idx_bookings_check_in ON bookings(check_in);
CREATE INDEX IF NOT EXISTS idx_bookings_check_out ON bookings(check_out);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_bookings_room_status_dates ON bookings(room_id, status, check_in, check_out);

-- 11. REVOKE DIRECT TABLE ACCESS FOR ANON
REVOKE ALL ON bookings FROM anon;
REVOKE ALL ON rooms FROM anon;

GRANT INSERT ON bookings TO anon;
GRANT SELECT ON rooms TO anon;

-- 12. STANDARDIZE STATUS VALUES
UPDATE bookings SET status = 'active' WHERE status = 'pending';
UPDATE bookings SET status = 'active' WHERE status = 'confirmed';

ALTER TABLE bookings DROP CONSTRAINT IF EXISTS bookings_status_check;
ALTER TABLE bookings ADD CONSTRAINT bookings_status_check
  CHECK (status IN ('active', 'cancelled', 'completed'));

-- 13. DATA CLEANUP & INTEGRITY CONSTRAINTS
-- Fix existing phone numbers (strip junk, keep last 10 digits)
UPDATE bookings 
SET phone = RIGHT(regexp_replace(phone, '[^0-9]', '', 'g'), 10)
WHERE phone IS NOT NULL AND length(regexp_replace(phone, '[^0-9]', '', 'g')) >= 10;

ALTER TABLE bookings DROP CONSTRAINT IF EXISTS bookings_customer_name_check;
ALTER TABLE bookings ADD CONSTRAINT bookings_customer_name_check
  CHECK (length(trim(customer_name)) >= 2);

ALTER TABLE bookings DROP CONSTRAINT IF EXISTS bookings_phone_check;
ALTER TABLE bookings ADD CONSTRAINT bookings_phone_check
  CHECK (phone IS NULL OR length(regexp_replace(phone, '[^0-9]', '', 'g')) >= 10);

-- Additional strict constraint: phone must be at least 10 digits if present
ALTER TABLE bookings DROP CONSTRAINT IF EXISTS phone_length_check;
ALTER TABLE bookings ADD CONSTRAINT phone_length_check
  CHECK (phone IS NULL OR length(regexp_replace(phone, '[^0-9]', '', 'g')) >= 10);

ALTER TABLE bookings DROP CONSTRAINT IF EXISTS bookings_dates_check;
ALTER TABLE bookings ADD CONSTRAINT bookings_dates_check
  CHECK (check_out > check_in);

-- 14. RPC FOR AVAILABILITY CHECK (M6 fix — replaces fetching all bookings)
DROP FUNCTION IF EXISTS get_room_availability(DATE, DATE);
DROP FUNCTION IF EXISTS get_room_availability(TEXT, DATE, DATE);
CREATE OR REPLACE FUNCTION get_room_availability(
  p_property_id TEXT,
  p_check_in DATE,
  p_check_out DATE
)
RETURNS TABLE (
  room_id UUID,
  room_name TEXT,
  total_rooms INTEGER,
  booked_count INTEGER,
  available_count INTEGER,
  price NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id AS room_id,
    r.name AS room_name,
    r.total_rooms,
    COALESCE(
      (SELECT COUNT(*)
       FROM bookings b
       WHERE b.room_id = r.id
         AND b.status = 'active'
         AND b.check_in < p_check_out
         AND b.check_out > p_check_in),
      0
    ) AS booked_count,
    r.total_rooms - COALESCE(
      (SELECT COUNT(*)
       FROM bookings b
       WHERE b.room_id = r.id
         AND b.status = 'active'
         AND b.check_in < p_check_out
         AND b.check_out > p_check_in),
      0
    ) AS available_count,
    r.price
  FROM rooms r
  WHERE r.property_id = COALESCE(p_property_id, 'sreekrishna')
  ORDER BY r.price ASC;
END;
$$;

-- Grant execute permissions (specify args to resolve ambiguity if old ones accidentally linger)
GRANT EXECUTE ON FUNCTION create_booking_safe(TEXT, UUID, DATE, DATE, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION check_rate_limit(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_room_availability(TEXT, DATE, DATE) TO anon, authenticated;

-- 15. ANALYTICS RPC — BOOKING TREND
DROP FUNCTION IF EXISTS get_booking_trend(INTEGER);
DROP FUNCTION IF EXISTS get_booking_trend(TEXT, INTEGER);
CREATE OR REPLACE FUNCTION get_booking_trend(p_property_id TEXT, p_days INTEGER)
RETURNS TABLE (
  date DATE,
  bookings BIGINT,
  revenue NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.date::DATE,
    COUNT(b.id) AS bookings,
    COALESCE(SUM(b.price_at_booking * b.nights), 0) AS revenue
  FROM (
    SELECT (CURRENT_DATE - (i || ' days')::INTERVAL)::DATE AS date
    FROM generate_series(0, p_days - 1) i
  ) d
  LEFT JOIN bookings b ON d.date = b.created_at::DATE AND b.status = 'active' AND b.property_id = COALESCE(p_property_id, 'sreekrishna')
  GROUP BY d.date
  ORDER BY d.date ASC;
END;
$$;

-- 16. ANALYTICS RPC — REVENUE BY ROOM
DROP FUNCTION IF EXISTS get_revenue_by_room(DATE, DATE);
CREATE OR REPLACE FUNCTION get_revenue_by_room(p_from DATE DEFAULT NULL, p_to DATE DEFAULT NULL)
RETURNS TABLE (
  room_name TEXT,
  total_revenue NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.name AS room_name,
    COALESCE(SUM(b.price_at_booking * b.nights), 0) AS total_revenue
  FROM rooms r
  LEFT JOIN bookings b ON r.id = b.room_id 
    AND b.status = 'active'
    AND (p_from IS NULL OR b.check_in >= p_from)
    AND (p_to IS NULL OR b.check_in <= p_to)
  GROUP BY r.name
  ORDER BY total_revenue DESC;
END;
$$;

-- 17. ANALYTICS RPC — REPEAT GUESTS
DROP FUNCTION IF EXISTS get_repeat_guests();
CREATE OR REPLACE FUNCTION get_repeat_guests()
RETURNS TABLE (
  guest_name TEXT,
  phone TEXT,
  visit_count BIGINT,
  total_spent NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    MAX(customer_name) AS guest_name,
    bookings.phone,
    COUNT(*) AS visit_count,
    SUM(price_at_booking * nights) AS total_spent
  FROM bookings
  WHERE status IN ('active', 'completed')
  GROUP BY bookings.phone
  HAVING COUNT(*) > 1
  ORDER BY visit_count DESC, total_spent DESC;
END;
$$;

-- 18. AUDIT LOG TABLE & TRIGGER
CREATE TABLE IF NOT EXISTS audit_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  user_id UUID,
  user_name TEXT,
  user_role TEXT,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  old_value JSONB,
  new_value JSONB
);

ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_manager_audit_log_select" ON audit_log;
CREATE POLICY "allow_manager_audit_log_select"
  ON audit_log FOR SELECT
  TO authenticated
  USING (
    auth.jwt() ->> 'role' = 'manager'
    AND auth.jwt() -> 'user_metadata' ->> 'property_id' = property_id
  );

-- Trigger function for booking status changes
CREATE OR REPLACE FUNCTION audit_booking_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'UPDATE') THEN
    IF (OLD.status != NEW.status OR OLD.is_seen != NEW.is_seen) THEN
      INSERT INTO audit_log (user_id, user_role, action, entity_type, entity_id, old_value, new_value)
      VALUES (
        auth.uid(),
        auth.jwt() ->> 'role',
        'UPDATE',
        'booking',
        NEW.id,
        jsonb_build_object('status', OLD.status, 'is_seen', OLD.is_seen),
        jsonb_build_object('status', NEW.status, 'is_seen', NEW.is_seen)
      );
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_audit_bookings ON bookings;
CREATE TRIGGER trg_audit_bookings
  AFTER UPDATE ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION audit_booking_changes();

-- Grant permissions for new functions
GRANT EXECUTE ON FUNCTION get_booking_trend(TEXT, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_revenue_by_room(DATE, DATE) TO authenticated;
GRANT EXECUTE ON FUNCTION get_repeat_guests() TO authenticated;
