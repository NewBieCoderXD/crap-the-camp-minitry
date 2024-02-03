START TRANSACTION;

CALL pay('2023-05-11',1,'บางหว้า');
CALL delete_booking('admin1@gmail.com','2023-05-11','1','บางหว้า');

SELECT * FROM "Booking";
SELECT * FROM "delete";
-- ERROR already paid
COMMIT;

START TRANSACTION;
CALL delete_booking('admin1@gmail.com','2023-05-11','2','บางหว้า');

SELECT * FROM "Booking";
SELECT * FROM "delete";
-- OK
COMMIT;

START TRANSACTION;
CALL delete_booking('2@gmail.com','2023-05-20','1','บางพวย');

SELECT * FROM "Booking";
SELECT * FROM "delete";
-- ERROR permission
COMMIT;