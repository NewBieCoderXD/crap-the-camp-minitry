CREATE OR REPLACE FUNCTION on_booking_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO "delete" VALUES (OLD.address,OLD.employee_id,OLD.customer_id,OLD.in_date);
   RETURN NEW;
END;
$$;