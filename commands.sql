DROP TABLE IF EXISTS "delete";
DROP TABLE IF EXISTS "owns";
DROP TABLE IF EXISTS "Transaction" CASCADE;
DROP TABLE IF EXISTS "User" CASCADE;
DROP TABLE IF EXISTS "Customer" CASCADE;
DROP TABLE IF EXISTS "Admin" CASCADE;
DROP TABLE IF EXISTS "PlaceOwner" CASCADE;
DROP TABLE IF EXISTS "Place" CASCADE;
DROP TABLE IF EXISTS "Booking" CASCADE;

CREATE TABLE "User"(
  email VARCHAR(320) PRIMARY KEY,
  name VARCHAR NOT NULL,
  password VARCHAR(40) NOT NULL,
  phone VARCHAR(16)
);

CREATE TABLE "Customer"(
  email VARCHAR(320) UNIQUE NOT NULL REFERENCES "User" (email),
  customer_id INTEGER UNIQUE NOT NULL,
  PRIMARY KEY(email,customer_id)
);

CREATE TABLE "Admin"(
  email VARCHAR(320) UNIQUE NOT NULL REFERENCES "User" (email),
  employee_id INTEGER UNIQUE NOT NULL,
  PRIMARY KEY(email,employee_id)
);

CREATE TABLE "PlaceOwner"(
  email VARCHAR(320) UNIQUE NOT NULL REFERENCES "User" (email),
  ownerId INTEGER UNIQUE NOT NULL,
  PRIMARY KEY(email,ownerId)
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
   ownerId INTEGER NOT NULL REFERENCES "PlaceOwner" (ownerId),                                                         
   address VARCHAR NOT NULL REFERENCES "Place" (address),                                                              
   PRIMARY KEY (ownerId, address)                                                                                      
);                   

CREATE TABLE "delete"(
   address VARCHAR NOT NULL REFERENCES "Place" (address),
   employee_id INTEGER NOT NULL REFERENCES "Admin" (employee_id),
   customer_id INTEGER NOT NULL REFERENCES "Customer" (customer_id),
   in_date DATE NOT NULL,
   PRIMARY KEY (address,employee_id,customer_id,in_date),
   FOREIGN KEY (customer_id,address,in_date) REFERENCES "Booking" (customer_id,address,in_date)
);

CREATE OR REPLACE FUNCTION on_booking_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
$$
BEGIN
   INSERT INTO "delete" VALUES (OLD.address,OLD.employee_id,OLD.customer_id,OLD.in_date);
   RETURN NEW;
END;
$$;