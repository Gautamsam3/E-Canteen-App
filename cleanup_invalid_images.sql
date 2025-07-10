-- Script to clean up menu items without valid images
-- Run this in your Supabase SQL Editor to remove menu items with invalid or missing images

-- 1. First, let's see which items have invalid images (for review)
SELECT id, name, image_url, 
       CASE 
         WHEN image_url IS NULL THEN 'NULL'
         WHEN image_url = '' THEN 'EMPTY'
         WHEN LENGTH(image_url) < 10 THEN 'TOO_SHORT'
         WHEN image_url NOT LIKE 'http%' THEN 'INVALID_PROTOCOL'
         ELSE 'VALID'
       END as image_status
FROM menu_items
WHERE image_url IS NULL 
   OR image_url = '' 
   OR LENGTH(image_url) < 10
   OR image_url NOT LIKE 'http%';

-- 2. Delete menu items with completely missing or invalid image URLs
DELETE FROM menu_items 
WHERE image_url IS NULL 
   OR image_url = '' 
   OR LENGTH(image_url) < 10
   OR image_url NOT LIKE 'http%';

-- 3. Update any remaining items to ensure proper Unsplash formatting
UPDATE menu_items 
SET image_url = CASE 
  WHEN image_url LIKE '%unsplash.com%' AND image_url NOT LIKE '%w=%' THEN 
    image_url || '?w=500&h=400&fit=crop'
  WHEN image_url LIKE '%unsplash.com%' AND image_url LIKE '%?%' AND image_url NOT LIKE '%w=%' THEN 
    image_url || '&w=500&h=400&fit=crop'
  ELSE image_url
END
WHERE image_url LIKE '%unsplash.com%';

-- 4. Create a function to validate image URLs (optional - for future use)
CREATE OR REPLACE FUNCTION is_valid_image_url(url text)
RETURNS boolean
LANGUAGE plpgsql
AS $$
BEGIN
  -- Check if URL is not null and not empty
  IF url IS NULL OR url = '' THEN
    RETURN false;
  END IF;
  
  -- Check if URL starts with http or https
  IF url NOT LIKE 'http%' THEN
    RETURN false;
  END IF;
  
  -- Check minimum length
  IF LENGTH(url) < 10 THEN
    RETURN false;
  END IF;
  
  -- Additional checks can be added here
  RETURN true;
END;
$$;

-- 5. Create a trigger to prevent insertion of menu items with invalid images
CREATE OR REPLACE FUNCTION validate_menu_item_image()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT is_valid_image_url(NEW.image_url) THEN
    RAISE EXCEPTION 'Invalid image URL: %', NEW.image_url;
  END IF;
  
  RETURN NEW;
END;
$$;

-- 6. Apply the trigger
DROP TRIGGER IF EXISTS validate_image_url_trigger ON menu_items;
CREATE TRIGGER validate_image_url_trigger
  BEFORE INSERT OR UPDATE ON menu_items
  FOR EACH ROW
  EXECUTE FUNCTION validate_menu_item_image();

-- 7. Final verification - show all remaining menu items with their image status
SELECT id, name, image_url, is_valid_image_url(image_url) as is_valid
FROM menu_items
ORDER BY name;
