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
DROP PROCEDURE delete_booking;

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
   phone VARCHAR(16) NOT NULL
);

CREATE TABLE "Booking"(
   in_date DATE NOT NULL,
   customer_id INTEGER NOT NULL REFERENCES "Customer" (customer_id),
   address VARCHAR NOT NULL REFERENCES "Place" (address),
   price DECIMAL NOT NULL,
   out_date DATE NOT NULL,
   PRIMARY KEY (in_date, customer_id, address)
);

CREATE TABLE "Transaction"(                                                                    
   in_date DATE NOT NULL,                                                                                              
   customer_id INTEGER NOT NULL REFERENCES "Customer" (customer_id),                                                     
   address VARCHAR NOT NULL REFERENCES "Place" (address),                                                              
   pay_date DATE NOT NULL,                                                                                             
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
   price DECIMAL NOT NULL,
   delete_timestamp TIMESTAMP NOT NULL,
   PRIMARY KEY (address,deleter_email,booking_owner_id,delete_timestamp)
);

CREATE TABLE "edit"(
   address VARCHAR NOT NULL REFERENCES "Place" (address),
   editor_email VARCHAR NOT NULL REFERENCES "User" (email),
   booking_owner_id INTEGER NOT NULL REFERENCES "Customer" (customer_id),
   in_date DATE NOT NULL,
   out_date DATE NOT NULL,
   price DECIMAL NOT NULL,
   edit_timestamp TIMESTAMP NOT NULL,
   PRIMARY KEY (address,editor_email,booking_owner_id,edit_timestamp),
   FOREIGN KEY (address,booking_owner_id,in_date) REFERENCES "Booking"(address,customer_id,in_date)
);

CREATE OR REPLACE PROCEDURE edit_booking(
   editor_email VARCHAR,
   booking_owner_id INTEGER,
   old_in_date DATE,
   old_address VARCHAR,
   
   new_in_date DATE,
   new_out_date DATE,
   new_address VARCHAR,
   new_price DECIMAL
)
LANGUAGE plpgsql
AS
$$
DECLARE
   old_price DECIMAL;
   old_out_date DATE;
BEGIN
   IF NOT EXISTS (
      SELECT 1 FROM "Booking"
      WHERE old_in_date="Booking".in_date
      AND booking_owner_id="Booking".customer_id
      AND old_address="Booking".address
   ) THEN
      RAISE EXCEPTION 'Booking doesn''t exist';
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
      SELECT "Booking".price, "Booking".out_date INTO old_price,old_out_date FROM "Booking" 
      WHERE "Booking".in_date=old_in_date
      AND "Booking".customer_id=booking_owner_id
      AND "Booking".address=old_address;

      INSERT INTO edit VALUES (old_address,editor_email,booking_owner_id,old_in_date,old_out_date,old_price,NOW());
      UPDATE "Booking"
      SET "Booking".
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
      WHERE deleted_in_date="Booking".in_date
      AND booking_owner_id="Booking".customer_id
      AND deleted_address="Booking".address
   ) THEN
      RAISE EXCEPTION 'Booking doesn''t exist';
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
      SELECT "Booking".price, "Booking".out_date INTO price,out_date FROM "Booking" 
      WHERE "Booking".in_date=deleted_in_date
      AND "Booking".customer_id=booking_owner_id
      AND "Booking".address=deleted_address;

      RAISE NOTICE '% %', price, out_date;

      DELETE FROM "Booking"
      WHERE "Booking".in_date=deleted_in_date
      AND "Booking".customer_id=booking_owner_id
      AND "Booking".address=deleted_address;

      INSERT INTO "delete"
      VALUES (deleted_address,deleter_email,booking_owner_id,deleted_in_date,out_date,price,NOW());
   END IF;
END;
$$;