BEGIN;

INSERT INTO "User" VALUES
('1@gmail.com','ahfong naja','#$NWKFD','000-0000-000'),
('2@gmail.com','ahfong naja','#$NWKFD','000-0000-000'),
('admin1@gmail.com','ahfong naja','#$NWKFD','000-0000-000'),
('admin2@gmail.com','ahfong naja','#$NWKFD','000-0000-000');

INSERT INTO "Customer" VALUES 
('1@gmail.com',1),
('2@gmail.com',2);

INSERT INTO "Admin" VALUES 
('admin1@gmail.com',1),
('admin2@gmail.com',2);

INSERT INTO "Place" VALUES 
('บางหว้า',50,'000-0000-000',20),
('บางพวย',50,'000-0000-000',20);

INSERT INTO "Booking" VALUES 
('2023-05-11','1','บางหว้า','2023-05-13');

INSERT INTO "Booking" VALUES 
('2023-05-11','2','บางหว้า','2023-05-13');

INSERT INTO "Booking" VALUES
('2023-05-20','1','บางพวย','2023-05-22');

COMMIT;