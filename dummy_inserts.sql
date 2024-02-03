BEGIN;

INSERT INTO "User" VALUES
('gg@gmail.com','ahfong naja','#$NWKFD','000-0000-000'),
('ga@gmail.com','ahfong naja','#$NWKFD','000-0000-000'),
('123@gmail.com','ahfong naja','#$NWKFD','000-0000-000'),
('456@gmail.com','ahfong naja','#$NWKFD','000-0000-000');

INSERT INTO "Customer" VALUES 
('gg@gmail.com',1),
('ga@gmail.com',2);

INSERT INTO "Admin" VALUES 
('123@gmail.com',1),
('456@gmail.com',2);

INSERT INTO "Place" VALUES 
('บางหว้า',50,'000-0000-000');

INSERT INTO "Booking" VALUES 
('2023-05-11','1','บางหว้า',50,'2023-05-13');

CALL pay('2023-05-11',1,'บางหว้า');
SELECT * FROM "Booking" NATURAL JOIN "Transaction";

-- CALL edit_booking('456@gmail.com',1,'2023-05-11','บางหว้า', '2023-05-12','2023-05-13','บางหว้า',50);
-- -- CALL delete_booking('123@gmail.com','2023-05-11','1','บางหว้า');

-- SELECT * FROM "Booking";

-- SELECT * FROM "edit";
-- SELECT * FROM "delete";

COMMIT;