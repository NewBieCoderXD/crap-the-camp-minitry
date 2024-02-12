WITH paid_booking AS (
    SELECT * 
    FROM "Transaction" 
    INNER JOIN "Booking" 
    USING(in_date,customer_id,address)
),count_booking  AS (
    SELECT paid_booking.address, count(*) AS count 
    FROM "Place" 
    LEFT JOIN paid_booking 
    USING(address) 
    WHERE '2023-05-12'::DATE BETWEEN paid_booking.in_date AND paid_booking.out_date
    GROUP BY paid_booking.address
)
SELECT "Place".*, capacity-count_booking.count AS available_capacity
FROM "Place" 
INNER JOIN count_booking 
USING(address)
WHERE "Place".capacity>count_booking.count;