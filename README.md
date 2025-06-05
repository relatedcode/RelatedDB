## What is this?

RelatedDB is a lightweight Swift wrapper for [SQLite](https://sqlite.org/faq.html) that simplifies database operations in iOS applications.

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Swift and Objective-C Cocoa projects.

To integrate **RelatedDB** into your Xcode project using CocoaPods, add the following line to your `Podfile`:

```ruby
pod 'RelatedDB'
```

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager) is a tool for managing the distribution of Swift code.

To add **RelatedDB** using Swift Package Manager, include it in the dependencies section of your `Package.swift` file:

```swift
dependencies: [ .package(url: "https://github.com/relatedcode/RelatedDB.git", from: "1.1.8") ]
```

### Manually

If you prefer not to use any of the dependency managers, you can integrate **RelatedDB** into your project manually. Just copy all the `*.swift` files from the `RelatedDB/Sources` folder into your Xcode project.

## Usage

### Connect to a Database

```swift
import RelatedDB

let db = RDatabase()
```

You can also specify a custom database filename or the complete file path. The default filename is `database.sqlite`, and the default directory is `Library/Application Support`.


```swift
let db = RDatabase(file: "db.sqlite")
```

```swift
let db = RDatabase(path: "yourpath/db.sqlite")
```

### Define an Object

RelatedDB provides a protocol that allows you to manipulate database rows as regular objects.

```swift
class User: NSObject, RDObject {

  @objc var userId = 0
  @objc var name = ""
  @objc var age = 0
  @objc var approved = false

  class func primaryKey() -> String {
    return "userId"
  }
}
```

Based on the User class definition above, RelatedDB will automatically create the following SQLite table:

```sql
CREATE TABLE IF NOT EXISTS User (userId INTEGER PRIMARY KEY NOT NULL, name TEXT, age INTEGER, approved INTEGER);
```

> **Note**: Since all the RDObject class property names will be used in SQLite commands, try to avoid using [SQLite keywords](https://sqlite.org/lang_keywords.html) in your class definition.

### Insert Object

Using the User class above, creating an object would look like this:

```swift
let user = User()

user.userId = 1001
user.name = "John Smith"
user.age = 42
user.approved = false

user.insert(db)
```

### Update Object

An existing object can be updated:

```swift
user.age = 43

user.update(db)
```

### Insert vs. Update

If you're unsure whether an object already exists in the database, you can use the following methods:

```swift
user.insertUpdate(db)
```

It will try to execute the INSERT command first and if it fails (silently), then executes the UPDATE command.

Also, you can use

```swift
user.updateInsert(db)
```

which will try to execute the UPDATE command first and if it fails (silently), then executes the INSERT command.

### Delete Object

An existing object can be deleted:

```swift
user.delete(db)
```

### Fetch Object(s)

Fetching one object would look like:

```swift
let user = User.fetchOne(db, key: 1001)
```

Fetching multiple objects can be done in the following ways:

```swift
let users = User.fetchAll(db)

let users = User.fetchAll(db, "age > 40")

let users = User.fetchAll(db, "age = ?", [42])

let users = User.fetchAll(db, "age >= :min AND age <= :max", [":min": 18, ":max": 99])
```

You can also use the `limit` and `offset` parameters.

```swift
let users = User.fetchAll(db, limit: 10)

let users = User.fetchAll(db, "age > 40", limit: 5, offset: 10)
```

### Serial Execution, Thread Safety

Database write operations are serialized, meaning Insert, Update, and Delete actions are executed sequentially (automatically managed by RelatedDB).

Fetch methods are thread-safe, ensuring that results are returned on the same thread from which the request was initiated.

> **Note**: You can initiate both read and write actions from any thread you like.

### Data Types

RelatedDB can manage the following data types: `Bool`, `Int8`, `Int16`, `Int32`, `Int64`, `Int`, `Float`, `Double`, `String`, `Date`, `Data`.

### Date Format

The `Date` values will be stored in the database as ISO formatted `String`. The default format is ISO 8601 ("1970-01-01T01:01:01.000Z"), produced by the `ISO8601DateFormatter` class.

You can also specify your own date format by using:

```swift
let formatter = DateFormatter()
formatter.locale = Locale(identifier: "en_US_POSIX")
formatter.timeZone = TimeZone(secondsFromGMT: 0)
formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

RDDate.custom(formatter)
```

> **Note**: You only need to specify the date format once in your codebase. Practically before doing any database action.

### Values Dictionary

Although managing the database rows as objects is an easy and elegant way, you might want to manage the data as `Dictionary` instead.

**Insert** *(using Dictionary)*

Insert a new object as Dictionary:

```swift
let values: [String: Any] = ["userId": 1001, "name": "John Smith", "age": 42, "approved": false]

db.insert("User", values)
```

**Update** *(using Dictionary)*

Update an existing object as Dictionary:

```swift
let values: [String: Any] = ["userId": 1001, "age": 43]

db.update("User", values)
```

The primary key must be included in the values Dictionary. Otherwise, nothing will happen.

**Fetch Result(s)** *(as Dictionary)*

Fetching one object as Dictionary:

```swift
let user = db.fetchOne("User", key: 1001)
```

In this case, the result type will be a `[String: Any]`.

Fetching multiple objects as Dictionary:

```swift
let users = db.fetchAll("User")

let users = db.fetchAll("User", "age > 40")

let users = db.fetchAll("User", "age = ?", [42])

let users = db.fetchAll("User", "age >= :min AND age <= :max", [":min": 18, ":max": 99])
```

In the cases above, the result types will be a `[[String: Any]]`.

**Convert Object** *(to Dictionary)*

Convert an existing object to a Dictionary:

```swift
let values = user.values()
```

**Date Values** (in Dictionary)

When using a values dictionary (for inserting or updating data), Date values can be provided as either `Date` objects or ISO-formatted `String` values.

When fetching data (as dictionary), the Date values will always be represented in the Dictionary as ISO formatted `String`.

### Batch Update

You can update multiple objects by specifying a condition.

```swift
let values = ["approved": true]

User.updateAll(db, values, "age >= ? AND age <= ?", [30, 35])
```

Alternatively, update one object by specifying the primary key value.

```swift
let values = ["approved": true]

User.updateOne(db, values, key: 1001)
```

### Batch Delete

You can delete multiple objects by specifying a condition.

```swift
User.deleteAll(db, "age >= ? AND age <= ?", [30, 35])
```

Alternatively delete one object by specifying the primary key value.

```swift
User.deleteOne(db, key: 1001)
```

### Count Objects

You can get the number of objects by specifying a condition.

```swift
let count = User.count(db)

let count = User.count(db, "age > 40")

let count = User.count(db, "age >= ? AND age <= ?", [30, 35])
```

### Check Objects

You can check whether an object exists or not (by specifying the primary key value).

```swift
if (User.check(db, key: 1001)) {
  // do something 
}
```

Or you can check whether a set of objects exist or not (by specifying a condition).

```swift
if (User.check(db, "age >= ? AND age <= ?", [30, 35])) {
  // do something 
}
```

### Create Observer

To refresh the user interface when database changes occur, you can use Database Observers.

To observe all possible changes for the User class:

```swift
let types: [RDObserverType] = [.insert, .update, .delete]

let observerId = User.createObserver(db, types) { method, objectId in
  // do something
}
```

However, you can narrow down the number of changes by using a condition:

```swift
let observerId = User.createObserver(db, types, "OBJ.age > 40") { method, objectId in
  // do something
}
```

Also you can check only specific database changes (separated or combined) by using the following Observer types: `.insert`, `.update`, `.delete`.

To get notified about new users, but not updated and/or deleted ones:

```swift
let observerId = User.createObserver(db, .insert) { method, objectId in
  // do something
}
```

Or to get notified about deleted users only:

```swift
let observerId = User.createObserver(db, .delete) { method, objectId in
  // do something
}
```

### Remove Observer

Once a Database Observer is no longer required, you can remove it by using:

```swift
User.removeObserver(db, observerId)
```

### Execute Plain SQL

If needed, you can execute plain SQL commands.

```swift
db.execute("DELETE FROM User WHERE age = 42;")
```

### Drop Table, Create Table

Although the SQLite tables are created automatically, you can also DROP and/or CREATE tables manually.

```swift
db.dropTable("User")

db.createTable("User")
```

In these cases, the `User` class also needs to be defined first.

### Cleanup Database

If needed, all tables can be destroyed and recreated using:

```swift
db.cleanupDatabase()
```

### Error Handling

Critical issues will trigger a `fatalError`, while other situations will be logged to the Xcode output window.

You can alter the debug level by using:

```swift
RDDebug.level(.none)

RDDebug.level(.error)

RDDebug.level(.all)
```

## Limitations

The RelatedDB toolkit is in its initial release. It is functional and can handle most workloads. However, there are some features that are currently not supported:

- Database migration
- Database encryption
- Combine framework integration

---

© Related Code 2025 - All Rights Reserved
