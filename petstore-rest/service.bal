import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string DB_URL = ?;
configurable string DB_USERNAME = ?;
configurable string DB_PASSWORD = ?;
configurable string DB_NAME = ?;

type Item record {|
    string code;
    string title;
    string description;
    string includes;
    string intended_for;
    string colour;
    string material;
    float price;
|};


# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    private final mysql:Client db;

    function init() returns error? {
        // Initiate the mysql client at the start of the service. This will be used
        // throughout the lifetime of the service.
        self.db = check new (DB_URL, DB_USERNAME, DB_PASSWORD, DB_NAME, 3306);
    }

    resource function get items() returns Item[]|error {
        // Execute simple query to retrieve all records from the `albums` table.
        stream<Item, sql:Error?> itemStream = self.db->query(`SELECT * FROM item`);

        // Process the stream and convert results to Album[] or return error.
        return from Item item in itemStream
            select item;
    }

    resource function post items(@http:Payload Item item) returns Item|error {
        _ = check self.db->execute(`
            INSERT INTO item (code, title, description, includes, intended_for, colour, material, price)
            VALUES (${item.code}, ${item.title}, ${item.description}, ${item.includes}, ${item.intended_for}, ${item.colour}, ${item.material}, ${item.price});`);
        return item;
    }
}

