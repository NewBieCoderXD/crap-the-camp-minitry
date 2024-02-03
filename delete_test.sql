START TRANSACTION;

CALL pay('2023-05-11',1,'บางหว้า');
CALL delete_booking('123@gmail.com','2023-05-11','1','บางหว้า');

SELECT * FROM "Booking";
SELECT * FROM "delete";
-- ERROR already paid
COMMIT;

START TRANSACTION;
CALL delete_booking('123@gmail.com','2023-05-11','2','บางหว้า');

SELECT * FROM "Booking";
SELECT * FROM "delete";
-- OK
COMMIT;