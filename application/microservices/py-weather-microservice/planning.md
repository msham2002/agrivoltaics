## MongoDB Schema
### User
```json
{
    "title": "user",
    "required": [
        "_id",
        "email",
        "last_read"
    ],
    "properties": {
        "_id": {"bsonType": "objectId"},
        "email": {"bsonType": "string"},
        "last_read": {"bsonType": "timestamp"}
    }
}
```

### Notification
```json
{
    "title": "notification",
    "required": [
        "_id",
        "body",
        "timestamp"
    ],
    "properties": {
        "_id": {"bsonType": "objectId"},
        "body": {"bsonType": "object"},
        "timestamp": {"bsonType": "timestamp"}
    }
}
```