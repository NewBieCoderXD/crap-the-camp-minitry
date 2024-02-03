START TRANSACTION;

CALL pay('2023-05-11',1,'บางหว้า');
SELECT * FROM "Booking" NATURAL JOIN "Transaction";
SELECT * FROM "Booking";
-- OK
COMMIT;

START TRANSACTION;

CALL pay('2023-05-11',1,'บางหว้า');
SELECT * FROM "Booking" NATURAL JOIN "Transaction";
SELECT * FROM "Booking";
-- ERROR already paid
COMMIT;