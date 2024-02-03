START TRANSACTION;
CALL logout('1@gmail.com');
SELECT * FROM "log";
COMMIT;