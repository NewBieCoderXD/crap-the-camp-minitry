CREATE TABLE "User"(
  email VARCHAR(320) PRIMARY KEY,
  name VARCHAR NOT NULL,
  password VARCHAR(40) NOT NULL,
  phone VARCHAR(16)
);

CREATE TABLE "Customer"(
  email VARCHAR(320) UNIQUE NOT NULL REFERENCES "User" (email),
  customerId INTEGER UNIQUE NOT NULL,
  PRIMARY KEY(email,customerId)
);

CREATE TABLE "Admin"(
  email VARCHAR(320) UNIQUE NOT NULL REFERENCES "User" (email),
  employeeId INTEGER UNIQUE NOT NULL,
  PRIMARY KEY(email,employeeId)
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
   customerId INTEGER NOT NULL REFERENCES "Customer" (customerId),
   address VARCHAR NOT NULL REFERENCES "Place" (address),
   price DECIMAL NOT NULL,
   out_date DATE NOT NULL,
   PRIMARY KEY (in_date, customerId, address)
);

CREATE TABLE "Transaction"(                                                                    
   in_date DATE NOT NULL,                                                                                              
   customerId INTEGER NOT NULL REFERENCES "Customer" (customerId),                                                     
   address VARCHAR NOT NULL REFERENCES "Place" (address),                                                              
   pay_date DATE NOT NULL,                                                                                             
   PRIMARY KEY (in_date, customerId, address)                                                                          
);    

CREATE TABLE "owns"(                                                                           
   ownerId INTEGER NOT NULL REFERENCES "PlaceOwner" (ownerId),                                                         
   address VARCHAR NOT NULL REFERENCES "Place" (address),                                                              
   PRIMARY KEY (ownerId, address)                                                                                      
);                   

CREATE TABLE "delete"(
   address VARCHAR NOT NULL REFERENCES "Place" (address),
   employeeId INTEGER NOT NULL REFERENCES "Admin" (employeeId),
   customerId INTEGER NOT NULL REFERENCES "Customer" (customerId),
   in_date DATE NOT NULL,
   PRIMARY KEY (address,employeeId,customerId,in_date),
   FOREIGN KEY (customerId,address,in_date) REFERENCES "Booking" (customerId,address,in_date)
);

