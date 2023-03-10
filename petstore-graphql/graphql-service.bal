import ballerina/graphql;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string DB_URL = ?;
configurable string DB_USERNAME = ?;
configurable string DB_PASSWORD = ?;
configurable string DB_NAME = ?;

public type ItemRecord record{|
    string code;
    string title;
    string description;
    string includes;
    string intended_for;
    string colour;
    string material;
    float price;
|};

public distinct service class Item {
    private final ItemRecord itemRecord;

    function init(ItemRecord itemRecord) {
      self.itemRecord= itemRecord;
    }

    resource function get code() returns string {
        return self.itemRecord.code;
    }

    resource function get title() returns string {
        return self.itemRecord.title;
    }

    resource function get description() returns string {
        return self.itemRecord.description;
    }

    resource function get includes() returns string {
        return self.itemRecord.includes;
    }

    resource function get intended_for() returns string {
        return self.itemRecord.intended_for;
    }

    resource function get colour() returns string {
        return self.itemRecord.colour;
    }

    resource function get material() returns string {
        return self.itemRecord.material;
    }

    resource function get price() returns float {
        return self.itemRecord.price;
    }
}

service /items on new graphql:Listener(9000) {

    private final mysql:Client db;

    function init() returns error? {
        // Initiate the mysql client at the start of the service. This will be used
        // throughout the lifetime of the service.
        self.db = check new (DB_URL, DB_USERNAME, DB_PASSWORD, DB_NAME, 3306, connectionPool={maxOpenConnections: 3});
    }
    
    resource function get all() returns Item[] | error? {
        // TODO: Use parameterized query to retrieve records from the `item` table.
        stream<ItemRecord, sql:Error?> itemStream = self.db->query(`SELECT * FROM item`);
        ItemRecord[] itemRecords = check from ItemRecord itemRecord in itemStream
                        select itemRecord;
        return itemRecords.map(entry => new Item(entry));
    }

    resource function get filter(string itemCode) returns Item | error? {
        // TODO: Use parameterized query to retrieve records from the `item` table.
        stream<ItemRecord, sql:Error?> itemStream = self.db->query(`SELECT * FROM item WHERE code = ${itemCode}`);
        ItemRecord[] itemRecords = check from ItemRecord itemRecord in itemStream
                        select itemRecord;
        return new Item(itemRecords[0]);
    }
}
