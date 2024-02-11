db.createCollection(
   "User",
   {
      validator: {
         $jsonSchema: {
            bsonType: "object",
            title: "User",
            required: ["email","phone","name","password"],
            properties:{
               "_id":{"bsonType": "objectId"},
               "name":{bsonType:"string"},
               "phone":{
                  bsonType:"string",
                  pattern:"^[0-9]{3}-[0-9]{3}-[0-9]{4}$"
               },
               "email":{
                  bsonType:"string",
                  pattern:"@"
               },
               "password":{
                  bsonType:"string"
               },
               "customer_id":{
                  bsonType:"int",
                  minimum:0
               },
               "owner_id":{
                  bsonType:"int",
                  minimum:0
               },
               "employee_id":{
                  bsonType:"int",
                  minimum:0
               },
               "bookings":{
                  bsonType:"array",
                  items:{
                     bsonType:"object",
                     required: ['in_date','out_date','address','transaction_pay_date'],
                     properties:{
                        "in_date":{"bsonType":"date"},
                        "out_date":{"bsonType":"date"},
                        "address":{"bsonType":"string"},
                        "transaction_pay_date":{"bsonType":"date"}
                     }
                  }
               }
            }
         }
      }
   }
)