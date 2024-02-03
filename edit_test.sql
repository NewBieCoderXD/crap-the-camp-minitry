START TRANSACTION;

CALL pay('2023-05-11',1,'บางหว้า');
CALL edit_booking('admin1@gmail.com',1,'2023-05-11','บางหว้า', '2023-05-12','2023-05-13','บางหว้า');

SELECT * FROM "Booking";
SELECT * FROM "edit";
-- ERROR already paid
COMMIT;

START TRANSACTION;
CALL edit_booking('admin1@gmail.com',2,'2023-05-11','บางหว้า', '2023-05-12','2023-05-13','บางหว้า');

SELECT * FROM "Booking";
SELECT * FROM "edit";
-- OK
COMMIT;

START TRANSACTION;
CALL edit_booking('1@gmail.com',2,'2023-05-12','บางหว้า', '2023-05-11','2023-05-13','บางหว้า');

SELECT * FROM "Booking";
SELECT * FROM "edit";
-- ERROR: permission
COMMIT;