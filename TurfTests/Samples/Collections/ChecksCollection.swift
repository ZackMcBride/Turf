import Foundation
import Turf

final class ChecksCollection: Collection, IndexedCollection {
    typealias Value = Check

    let name = "Checks"
    let schemaVersion = UInt64(1)
    let valueCacheSize: Int? = 50

    let index: SecondaryIndex<ChecksCollection, IndexedProperties>
    let indexed = IndexedProperties()

    let associatedExtensions: [Extension]

    init() {
        index = SecondaryIndex(collectionName: name, properties: indexed, version: 0)
        associatedExtensions = [index]

        index.collection = self
    }

    func setUp(transaction: ReadWriteTransaction) throws {
        try transaction.registerCollection(self)
        try transaction.registerExtension(index)
    }

    func serializeValue(value: Value) -> NSData {
        return value.uuid.dataUsingEncoding(NSUTF8StringEncoding)!
    }

    func deserializeValue(data: NSData) -> Value? {
        if let uuid = String(data: data, encoding: NSUTF8StringEncoding) {
            return Check(uuid: uuid, name: "", isOpen: true, isCurrent: false, lineItemUuids: [])
        } else {
            return nil
        }
    }

    struct IndexedProperties: Turf.IndexedProperties {
        let isOpen = IndexedProperty<ChecksCollection, Bool>(name: "isOpen") { return $0.isOpen }
        let name = IndexedProperty<ChecksCollection, SQLiteOptional<String>>(name: "name") { return $0.name.toSQLite() }
        let isCurrent = IndexedProperty<ChecksCollection, Bool>(name: "isCurrent") { return $0.isCurrent }

        var allProperties: [IndexedPropertyFromCollection<ChecksCollection>] {
            return [isOpen.lift(), name.lift(), isCurrent.lift()]
        }

//        var bindings: [String: (value: ChecksCollection.Value, toSQLiteStmt: COpaquePointer, atIndex: Int32) -> Int32] { return [
//                isOpen.name: isOpen.bindPropertyValue,
//                name.name: name.bindPropertyValue,
//                isCurrent.name: isCurrent.bindPropertyValue
//            ]
//        }
//
//        var bindings2: [String: (SQLiteType.Type, (value: ChecksCollection.Value, toSQLiteStmt: COpaquePointer, atIndex: Int32) -> Int32)] { return [
//                isOpen.name: (isOpen.Type, isOpen.bindPropertyValue),
//                name.name: (name.Type, name.bindPropertyValue),
//                isCurrent.name: (isCurrent.Type, isCurrent.bindPropertyValue)
//            ]
//        }
    }
}