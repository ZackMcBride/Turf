import XCTest
import Turf

class BasicSample: XCTestCase {
    var collections: Collections!
    override func setUp() {
        super.setUp()

        collections = Collections()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
        let db = try! Database(path: "basic.sqlite", collections: collections)
        let connection = try! db.newConnection()

        var changeSetToken: String!

        connection.readTransaction { transaction in
            changeSetToken = transaction.readOnly(self.collections.LineItems)
                .registerPermamentChangeSetObserver { changeSet in
                    print(changeSet.changes)
                }
        }

        connection.readWriteTransaction { transaction in
            let checksCollection = transaction.readWrite(self.collections.Checks)
            let lineItemsCollection = transaction.readWrite(self.collections.LineItems)

            //Non secondary indexed query - todo make the generator deserialization lazy
//            for openCheck in checksCollection.allValues.lazy.filter({ return $0.isOpen }) {
//                print(openCheck.name)
//            }
//
//            for openCheck in checksCollection.findValuesWhere(checksCollection.indexed.isOpen.equals(true)) {
//                print(openCheck.name)
//            }

            checksCollection.setValue(Check(uuid: "1234", name: "A", isOpen: true, lineItemUuids: []), forKey: "1234")
            lineItemsCollection.setValue(LineItem(uuid: "1", name: "A", price: 1.0), forKey: "1234")

//            if let check = checksCollection.valueForKey("1234") {
//                checksCollection.setDestinationValuesInCollection(
//                    lineItemsCollection,
//                    forRelationship: checksCollection.relationships.lineItems,
//                    fromSource: check)
//
//                let _ = checksCollection.destinationValuesInCollection(
//                    lineItemsCollection,
//                    forRelationship: checksCollection.relationships.lineItems,
//                    fromSource: check)
//
//                let _ = checksCollection.destinationKeysForRelationship(
//                    checksCollection.relationships.lineItems,
//                    fromSource: check)
//
//            }
        }

        connection.readTransaction { transaction in
            transaction.readOnly(self.collections.LineItems)
                .unregisterPermamentChangeSetObserver(changeSetToken)
        }
    }
}