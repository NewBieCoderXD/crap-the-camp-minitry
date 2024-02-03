START TRANSACTION;
SELECT login('1@gmail.com','#$NWKFD');
SELECT * FROM "log";
COMMIT;

START TRANSACTION;
SELECT login('1@gmail.com','no password');
SELECT * FROM "log";
COMMIT;