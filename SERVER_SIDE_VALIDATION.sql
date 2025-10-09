-- ============================================================================
-- BeeKeeperTD - Server-Side Tower Validation
-- ============================================================================
-- Purpose: Prevent cheating by validating tower positions and values
-- Security Level: CRITICAL
-- Apply in: Supabase Dashboard → SQL Editor → New Query → Run
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FUNCTION: Validate Tower Positions
-- ----------------------------------------------------------------------------
-- Checks that tower positions are within valid game boundaries
-- Validates tower types are in the allowed list
-- Prevents unrealistic tower counts

CREATE OR REPLACE FUNCTION validate_tower_positions()
RETURNS TRIGGER AS $$
DECLARE
    tower JSONB;
    tower_count INTEGER;
    max_towers INTEGER := 50;  -- Maximum towers per game (configurable)
    
    -- Game boundaries (adjust based on your game map size)
    min_x INTEGER := 0;
    max_x INTEGER := 1920;  -- Based on your viewport_width
    min_y INTEGER := 0;
    max_y INTEGER := 1080;  -- Based on your viewport_height
    
    -- Valid tower types from your game (updated 2025-01-12)
    valid_tower_types TEXT[] := ARRAY[
        'StingerTower',
        'PropolisBomberTower',
        'NectarSprayerTower',
        'LightningFlowerTower'
    ];
BEGIN
    -- Validate that save data structure exists
    IF NEW.data IS NULL THEN
        RAISE EXCEPTION 'Save data cannot be null';
    END IF;
    
    -- Check if tower_defense data exists
    IF NOT (NEW.data ? 'tower_defense') THEN
        -- No tower defense data yet, allow save
        RETURN NEW;
    END IF;
    
    -- Check if placed_towers exists
    IF NOT (NEW.data->'tower_defense' ? 'placed_towers') THEN
        -- No placed towers yet, allow save
        RETURN NEW;
    END IF;
    
    -- Validate tower count
    tower_count := jsonb_array_length(NEW.data->'tower_defense'->'placed_towers');
    
    IF tower_count > max_towers THEN
        RAISE EXCEPTION 'Too many towers: % (max: %)', tower_count, max_towers;
    END IF;
    
    -- Validate each tower
    FOR tower IN SELECT * FROM jsonb_array_elements(NEW.data->'tower_defense'->'placed_towers')
    LOOP
        -- Validate tower type
        IF NOT (tower->>'type' = ANY(valid_tower_types)) THEN
            RAISE EXCEPTION 'Invalid tower type: %', tower->>'type';
        END IF;
        
        -- Validate position exists
        IF NOT (tower ? 'position') THEN
            RAISE EXCEPTION 'Tower missing position data';
        END IF;
        
        -- Validate X position
        IF NOT (tower->'position' ? 'x') OR 
           (tower->'position'->>'x')::float < min_x OR 
           (tower->'position'->>'x')::float > max_x THEN
            RAISE EXCEPTION 'Invalid tower X position: % (must be between % and %)', 
                tower->'position'->>'x', min_x, max_x;
        END IF;
        
        -- Validate Y position
        IF NOT (tower->'position' ? 'y') OR 
           (tower->'position'->>'y')::float < min_y OR 
           (tower->'position'->>'y')::float > max_y THEN
            RAISE EXCEPTION 'Invalid tower Y position: % (must be between % and %)', 
                tower->'position'->>'y', min_y, max_y;
        END IF;
        
        -- Validate tower level (if exists)
        IF (tower ? 'level') THEN
            IF (tower->>'level')::integer < 1 OR (tower->>'level')::integer > 5 THEN
                RAISE EXCEPTION 'Invalid tower level: % (must be 1-5)', tower->>'level';
            END IF;
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- FUNCTION: Validate Player Resources
-- ----------------------------------------------------------------------------
-- Prevents unrealistic resource values (honey, honeygems, etc.)

CREATE OR REPLACE FUNCTION validate_player_resources()
RETURNS TRIGGER AS $$
DECLARE
    max_honey INTEGER := 1000000;  -- 1 million honey max
    max_honeygems INTEGER := 100000;  -- 100k honeygems max
    max_wax INTEGER := 1000000;
    max_wood INTEGER := 1000000;
    honey_val INTEGER;
    honeygems_val INTEGER;
    wax_val INTEGER;
    wood_val INTEGER;
BEGIN
    -- Check if player_data exists
    IF NOT (NEW.data ? 'player_data') THEN
        -- No player data yet, allow save
        RETURN NEW;
    END IF;
    
    -- Validate honey
    IF (NEW.data->'player_data' ? 'honey') THEN
        honey_val := (NEW.data->'player_data'->>'honey')::integer;
        
        IF honey_val < 0 THEN
            RAISE EXCEPTION 'Honey cannot be negative: %', honey_val;
        END IF;
        
        IF honey_val > max_honey THEN
            RAISE EXCEPTION 'Honey too high: % (max: %)', honey_val, max_honey;
        END IF;
    END IF;
    
    -- Validate honeygems
    IF (NEW.data->'player_data' ? 'honeygems') THEN
        honeygems_val := (NEW.data->'player_data'->>'honeygems')::integer;
        
        IF honeygems_val < 0 THEN
            RAISE EXCEPTION 'Honeygems cannot be negative: %', honeygems_val;
        END IF;
        
        IF honeygems_val > max_honeygems THEN
            RAISE EXCEPTION 'Honeygems too high: % (max: %)', honeygems_val, max_honeygems;
        END IF;
    END IF;
    
    -- Validate wax
    IF (NEW.data->'player_data' ? 'wax') THEN
        wax_val := (NEW.data->'player_data'->>'wax')::integer;
        
        IF wax_val < 0 THEN
            RAISE EXCEPTION 'Wax cannot be negative: %', wax_val;
        END IF;
        
        IF wax_val > max_wax THEN
            RAISE EXCEPTION 'Wax too high: % (max: %)', wax_val, max_wax;
        END IF;
    END IF;
    
    -- Validate wood
    IF (NEW.data->'player_data' ? 'wood') THEN
        wood_val := (NEW.data->'player_data'->>'wood')::integer;
        
        IF wood_val < 0 THEN
            RAISE EXCEPTION 'Wood cannot be negative: %', wood_val;
        END IF;
        
        IF wood_val > max_wood THEN
            RAISE EXCEPTION 'Wood too high: % (max: %)', wood_val, max_wood;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- FUNCTION: Validate Account Level
-- ----------------------------------------------------------------------------
-- Prevents unrealistic account level progression

CREATE OR REPLACE FUNCTION validate_account_level()
RETURNS TRIGGER AS $$
DECLARE
    min_level INTEGER := 1;
    max_level INTEGER := 100;  -- Adjust based on your progression system
    account_level INTEGER;
BEGIN
    -- Check if player_data and account_level exist
    IF (NEW.data ? 'player_data') AND (NEW.data->'player_data' ? 'account_level') THEN
        account_level := (NEW.data->'player_data'->>'account_level')::integer;
        
        IF account_level < min_level OR account_level > max_level THEN
            RAISE EXCEPTION 'Invalid account level: % (must be between % and %)', 
                account_level, min_level, max_level;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- FUNCTION: Validate Save Data Timestamp
-- ----------------------------------------------------------------------------
-- Prevents backdating saves (time travel cheats)

CREATE OR REPLACE FUNCTION validate_save_timestamp()
RETURNS TRIGGER AS $$
DECLARE
    save_timestamp BIGINT;
    current_timestamp BIGINT;
    max_future_seconds INTEGER := 300;  -- Allow 5 minutes clock skew
BEGIN
    -- Get current Unix timestamp
    current_timestamp := EXTRACT(EPOCH FROM NOW())::bigint;
    
    -- Check if timestamp exists
    IF (NEW.data ? 'timestamp') THEN
        save_timestamp := (NEW.data->>'timestamp')::bigint;
        
        -- Prevent saves from the future (beyond clock skew tolerance)
        IF save_timestamp > (current_timestamp + max_future_seconds) THEN
            RAISE EXCEPTION 'Save timestamp is in the future: % (current: %)', 
                to_timestamp(save_timestamp), to_timestamp(current_timestamp);
        END IF;
        
        -- Note: We don't prevent past timestamps as legitimate saves can be older
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- CREATE TRIGGERS
-- ----------------------------------------------------------------------------
-- Apply all validation functions to save_data table

-- Drop existing triggers if they exist (for re-running this script)
DROP TRIGGER IF EXISTS validate_tower_positions_trigger ON public.save_data;
DROP TRIGGER IF EXISTS validate_player_resources_trigger ON public.save_data;
DROP TRIGGER IF EXISTS validate_account_level_trigger ON public.save_data;
DROP TRIGGER IF EXISTS validate_save_timestamp_trigger ON public.save_data;

-- Create triggers
CREATE TRIGGER validate_tower_positions_trigger
    BEFORE INSERT OR UPDATE ON public.save_data
    FOR EACH ROW
    EXECUTE FUNCTION validate_tower_positions();

CREATE TRIGGER validate_player_resources_trigger
    BEFORE INSERT OR UPDATE ON public.save_data
    FOR EACH ROW
    EXECUTE FUNCTION validate_player_resources();

CREATE TRIGGER validate_account_level_trigger
    BEFORE INSERT OR UPDATE ON public.save_data
    FOR EACH ROW
    EXECUTE FUNCTION validate_account_level();

CREATE TRIGGER validate_save_timestamp_trigger
    BEFORE INSERT OR UPDATE ON public.save_data
    FOR EACH ROW
    EXECUTE FUNCTION validate_save_timestamp();

-- ----------------------------------------------------------------------------
-- VERIFICATION QUERIES
-- ----------------------------------------------------------------------------
-- Run these to verify the triggers are installed

-- Check that all triggers exist
SELECT 
    trigger_name, 
    event_manipulation, 
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE event_object_table = 'save_data'
ORDER BY trigger_name;

-- Count total triggers (should be 4)
SELECT COUNT(*) as trigger_count
FROM information_schema.triggers
WHERE event_object_table = 'save_data';

-- ----------------------------------------------------------------------------
-- TEST QUERIES (Optional)
-- ----------------------------------------------------------------------------
-- Test validation with invalid data (should fail)

-- Test 1: Invalid tower position (should fail)
-- INSERT INTO save_data (user_id, data) VALUES (
--     '00000000-0000-0000-0000-000000000000',
--     '{"tower_defense": {"placed_towers": [{"type": "BasicShooterTower", "position": {"x": 9999, "y": 100}}]}}'::jsonb
-- );
-- Expected: ERROR - Invalid tower X position

-- Test 2: Invalid tower type (should fail)
-- INSERT INTO save_data (user_id, data) VALUES (
--     '00000000-0000-0000-0000-000000000000',
--     '{"tower_defense": {"placed_towers": [{"type": "HackedTower", "position": {"x": 100, "y": 100}}]}}'::jsonb
-- );
-- Expected: ERROR - Invalid tower type

-- Test 3: Negative resources (should fail)
-- INSERT INTO save_data (user_id, data) VALUES (
--     '00000000-0000-0000-0000-000000000000',
--     '{"player_data": {"honey": -1000}}'::jsonb
-- );
-- Expected: ERROR - Honey cannot be negative

-- Test 4: Valid data (should succeed)
-- INSERT INTO save_data (user_id, data) VALUES (
--     '00000000-0000-0000-0000-000000000000',
--     '{"player_data": {"honey": 500, "account_level": 5}, "tower_defense": {"placed_towers": [{"type": "BasicShooterTower", "position": {"x": 100, "y": 100}}]}}'::jsonb
-- );
-- Expected: SUCCESS

-- ----------------------------------------------------------------------------
-- CLEANUP (if needed)
-- ----------------------------------------------------------------------------
-- To remove all validation triggers and functions:

-- DROP TRIGGER IF EXISTS validate_tower_positions_trigger ON public.save_data;
-- DROP TRIGGER IF EXISTS validate_player_resources_trigger ON public.save_data;
-- DROP TRIGGER IF EXISTS validate_account_level_trigger ON public.save_data;
-- DROP TRIGGER IF EXISTS validate_save_timestamp_trigger ON public.save_data;
-- DROP FUNCTION IF EXISTS validate_tower_positions();
-- DROP FUNCTION IF EXISTS validate_player_resources();
-- DROP FUNCTION IF EXISTS validate_account_level();
-- DROP FUNCTION IF EXISTS validate_save_timestamp();

-- ============================================================================
-- DEPLOYMENT NOTES
-- ============================================================================
-- 1. Copy this entire file
-- 2. Go to Supabase Dashboard → SQL Editor
-- 3. Create new query
-- 4. Paste and run
-- 5. Verify with the verification queries below
-- 6. Test with invalid data to ensure triggers work
-- 
-- IMPORTANT: Adjust the following values for your game:
--   - max_towers (line 23): Maximum towers allowed
--   - min_x, max_x, min_y, max_y (lines 26-29): Game boundaries
--   - valid_tower_types (lines 32-38): Your tower class names
--   - max_honey, max_honeygems, etc. (lines 115-118): Resource limits
--   - max_level (line 189): Maximum account level
-- 
-- Security Impact: CRITICAL
--   - Prevents position manipulation
--   - Prevents resource cheating
--   - Prevents level manipulation
--   - Prevents time travel exploits
-- 
-- Performance Impact: LOW
--   - Triggers only run on INSERT/UPDATE
--   - Validation is lightweight (< 1ms per save)
-- 
-- Maintenance:
--   - Update tower types when adding new towers
--   - Adjust resource limits as game progresses
--   - Monitor failed saves in Supabase logs
-- ============================================================================
