DROP TABLE IF EXISTS "delete";
DROP TABLE IF EXISTS "owns";
DROP TABLE IF EXISTS "Transaction" CASCADE;
DROP TABLE IF EXISTS "User" CASCADE;
DROP TABLE IF EXISTS "Customer" CASCADE;
DROP TABLE IF EXISTS "Admin" CASCADE;
DROP TABLE IF EXISTS "PlaceOwner" CASCADE;
DROP TABLE IF EXISTS "Place" CASCADE;
DROP TABLE IF EXISTS "Booking" CASCADE;
DROP TABLE IF EXISTS "edit" CASCADE;
DROP TABLE IF EXISTS "log";
DROP TYPE IF EXISTS "Log_Type";

DROP PROCEDURE IF EXISTS pay;
DROP PROCEDURE IF EXISTS edit_booking;
DROP PROCEDURE IF EXISTS delete_booking;

CREATE TABLE "User"(
  email VARCHAR(320) PRIMARY KEY,
  name VARCHAR NOT NULL,
  password VARCHAR(40) NOT NULL,
  phone VARCHAR(16)
);

CREATE TABLE "Customer"(
  email VARCHAR(320) PRIMARY KEY NOT NULL REFERENCES "User" (email),
  customer_id INTEGER UNIQUE NOT NULL
);

CREATE TABLE "Admin"(
  email VARCHAR(320) PRIMARY KEY NOT NULL REFERENCES "User" (email),
  employee_id INTEGER UNIQUE NOT NULL
);

CREATE TABLE "PlaceOwner"(
  email VARCHAR(320) PRIMARY KEY NOT NULL REFERENCES "User" (email),
  owner_id INTEGER UNIQUE NOT NULL
);

CREATE TABLE "Place"(
   address VARCHAR PRIMARY KEY NOT NULL,
   capacity INTEGER NOT NULL,
   phone VARCHAR(16) NOT NULL,
   price_per_day DECIMAL NOT NULL
);

CREATE TABLE "Booking"(
   in_date DATE NOT NULL,
   customer_id INTEGER NOT NULL REFERENCES "Customer" (customer_id),
   address VARCHAR NOT NULL REFERENCES "Place" (address),
   out_date DATE NOT NULL,
   PRIMARY KEY (in_date, customer_id, address),
   CONSTRAINT time_travel CHECK (out_date>=in_date AND EXTRACT(day FROM AGE(out_date,in_date)) <= 3)
);

CREATE TABLE "Transaction"(                                                                    
   in_date DATE NOT NULL,                                                                                              
   customer_id INTEGER NOT NULL REFERENCES "Customer" (customer_id),                                                     
   address VARCHAR NOT NULL REFERENCES "Place" (address),
   price DECIMAL NOT NULL,
   pay_timestamp TIMESTAMP NOT NULL,                                                                                             
   PRIMARY KEY (in_date, customer_id, address)                                                                          
);    

CREATE TABLE "owns"(                                                                           
   owner_id INTEGER NOT NULL REFERENCES "PlaceOwner" (owner_id),                                                         
   address VARCHAR NOT NULL REFERENCES "Place" (address),                                                              
   PRIMARY KEY (owner_id, address)                                                                                      
);                   

CREATE TABLE "delete"(
   address VARCHAR NOT NULL REFERENCES "Place" (address),
   deleter_email VARCHAR NOT NULL REFERENCES "User" (email),
   booking_owner_id INTEGER NOT NULL REFERENCES "Customer" (customer_id),
   in_date DATE NOT NULL,
   out_date DATE NOT NULL,
   delete_timestamp TIMESTAMP NOT NULL,
   PRIMARY KEY (address,deleter_email,booking_owner_id,delete_timestamp)
);

CREATE TABLE "edit"(
   address VARCHAR NOT NULL REFERENCES "Place" (address),
   editor_email VARCHAR NOT NULL REFERENCES "User" (email),
   booking_owner_id INTEGER NOT NULL REFERENCES "Customer" (customer_id),
   in_date DATE NOT NULL,
   out_date DATE NOT NULL,
   edit_timestamp TIMESTAMP NOT NULL,
   PRIMARY KEY (address,editor_email,booking_owner_id,edit_timestamp)
);

CREATE TYPE "Log_Type" AS ENUM(
   'login',
   'logout'
);

CREATE TABLE "log"(
   log_id SERIAL PRIMARY KEY,
   log_type "Log_Type",
   email VARCHAR,
   log_time TIMESTAMP
);

CREATE OR REPLACE FUNCTION login(
   user_email VARCHAR,
   password VARCHAR(40)
)
RETURNS boolean
LANGUAGE plpgsql
AS
$$
BEGIN
   IF EXISTS (
      SELECT 1 FROM "User"
      WHERE user_email="User".email
      AND login.password="User".password
   ) THEN
      INSERT INTO "log" (log_type,email,log_time) VALUES ('login',user_email,NOW());
      RETURN true;
   ELSE
      RETURN false;
   END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE logout(
   user_email VARCHAR
)
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO "log" (log_type,email,log_time) VALUES ('logout',user_email,NOW());
END;
$$;

CREATE OR REPLACE PROCEDURE booking_not_available_exception()
LANGUAGE plpgsql
AS
$$
BEGIN
   RAISE EXCEPTION 'Booking doesn''t exist, or was already paid';
END;
$$;

CREATE OR REPLACE PROCEDURE pay(
   in_date DATE,
   customer_id INT,
   address VARCHAR
) LANGUAGE plpgsql
AS
$$
DECLARE
   price_per_day DECIMAL;
   out_date DATE;
BEGIN
   SELECT "Booking".out_date, "Place".price_per_day INTO out_date,price_per_day
   FROM "Booking"
   LEFT OUTER JOIN "Transaction"
   USING (in_date,customer_id,address)
   NATURAL JOIN "Place"
   WHERE "Transaction".pay_timestamp is null
   AND pay.in_date="Booking".in_date
   AND pay.customer_id="Booking".customer_id
   AND pay.address="Booking".address;

   IF out_date IS NULL THEN
      CALL booking_not_available_exception();
   END IF;

   INSERT INTO "Transaction" VALUES (in_date,customer_id,address,(out_date-in_date)*price_per_day,NOW());
END
$$;

CREATE OR REPLACE PROCEDURE edit_booking(
   editor_email VARCHAR,
   booking_owner_id INTEGER,
   old_in_date DATE,
   old_address VARCHAR,
   
   new_in_date DATE,
   new_out_date DATE,
   new_address VARCHAR
)
LANGUAGE plpgsql
AS
$$
DECLARE
   old_out_date DATE;
BEGIN
   IF NOT EXISTS (
      SELECT 1 FROM "Booking"
      LEFT JOIN "Transaction"
      ON "Transaction".in_date="Booking".in_date
      AND "Transaction".customer_id="Booking".customer_id
      AND "Transaction".address="Booking".address
      WHERE "Transaction".pay_timestamp is null
      AND old_in_date="Booking".in_date
      AND booking_owner_id="Booking".customer_id
      AND old_address="Booking".address
   ) THEN
      CALL booking_not_available_exception();
   -- check if deleter is booking's owner or admin
   ELSIF editor_email <> (
      SELECT email FROM "Customer"
      WHERE booking_owner_id="Customer".customer_id
   ) AND NOT EXISTS(
      SELECT 1 FROM "Admin"
      WHERE editor_email="Admin".email
   ) THEN
      RAISE EXCEPTION 'No permission';
   ELSE
      SELECT "Booking".out_date INTO old_out_date FROM "Booking" 
      WHERE "Booking".in_date=old_in_date
      AND "Booking".customer_id=booking_owner_id
      AND "Booking".address=old_address;

      INSERT INTO edit VALUES (old_address,editor_email,booking_owner_id,old_in_date,old_out_date,NOW());

      UPDATE "Booking"
      SET address=new_address,
      in_date=new_in_date,
      out_date=new_out_date
      WHERE "Booking".in_date=old_in_date
      AND "Booking".customer_id=booking_owner_id
      AND "Booking".address=old_address;
   END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_booking(
   deleter_email VARCHAR,
   deleted_in_date DATE,
   booking_owner_id INTEGER,
   deleted_address VARCHAR
)
LANGUAGE plpgsql
AS
$$
DECLARE
   price DECIMAL;
   out_date DATE;
BEGIN
   IF NOT EXISTS (
      SELECT 1 FROM "Booking"
      LEFT JOIN "Transaction"
      ON "Transaction".in_date="Booking".in_date
      AND "Transaction".customer_id="Booking".customer_id
      AND "Transaction".address="Booking".address
      WHERE "Transaction".pay_timestamp is null
      AND deleted_in_date="Booking".in_date
      AND booking_owner_id="Booking".customer_id
      AND deleted_address="Booking".address
   ) THEN
      CALL booking_not_available_exception();
   -- check if deleter is booking's owner or admin
   ELSIF deleter_email <> (
      SELECT email FROM "Customer"
      WHERE booking_owner_id="Customer".customer_id
   ) AND NOT EXISTS(
      SELECT 1 FROM "Admin"
      WHERE deleter_email="Admin".email
   ) THEN
      RAISE EXCEPTION 'No permission';
   ELSE
      SELECT "Booking".out_date INTO out_date FROM "Booking" 
      WHERE "Booking".in_date=deleted_in_date
      AND "Booking".customer_id=booking_owner_id
      AND "Booking".address=deleted_address;

      DELETE FROM "Booking"
      WHERE "Booking".in_date=deleted_in_date
      AND "Booking".customer_id=booking_owner_id
      AND "Booking".address=deleted_address;

      INSERT INTO "delete"
      VALUES (deleted_address,deleter_email,booking_owner_id,deleted_in_date,out_date,NOW());
   END IF;
END;
$$;