---
layout: post
title: "Debugging 'object has no properties' in a MongoDB map/reduce"
redirect_from: "/debugging-object-has-no-properties-in-a-mongodb-mapreduce/"
date: 2012-11-29 12:48:12
tags: [mongoid, javascript, mongodb]
comments: true
---
You got to love debugging JavaScript errors. Here’s one from a MongoDB map/reduce. The operation fails with this:

```
04:39:41  Database command 'mapreduce' failed: (
    assertion: 'map invoke failed: JS Error:
        TypeError: spline has no properties nofile_b:7';
    assertionCode: '9014';
    errmsg: 'db assertion failure';
    ok: '0.0').
```

Examining the MongoDB log we notice that the map/reduce completes to about 70%, so this is caused by some data inside the database. In this case the issue is in the _spline_ object being accessed by the _map_ function. Indeed, the map tries to fetch _spline.reticulated_, which is hopefully a Boolean value. The error _"spline has no properties"_ is, generally, another way of saying _"spline is null"_. In my case splines live in an embedded collection inside _bones_, and aren’t expected to be _null_, so I need to track down a null _spline_ inside _bone.splines_.

While we can just look for a null embedded object, more generally, we can find whether a JS object has no properties with [this isEmpty function from SO](http://stackoverflow.com/questions/3426979/javascript-checking-if-an-object-has-no-properties-or-if-a-map-associative-arra). Declare it in the mongodb console (use a 1-liner):

```js
function isEmpty(map) {
    for(var key in map) {
        if (map.hasOwnProperty(key)) {
            return false;
        }
    }
    return true;
}
```

Iterate over all bones records.

```js
db.bones.find().forEach(function(bone) {
    if (bone.splines) {
        bone.splines.forEach(function(spline) {
            if (isEmpty(spline)) {
                printjson(bone);
            }
        }
    );
}});
```

Here’s the culprit, notice the null embedded _spline_.

```json
{
    "_id" : ObjectId("507ea06bd646a40002000759"),
    "splines" : [
        {
            "_id" : ObjectId("508a6911c6e210000200078c"),
                        ....
        },
        null
    ]
}
```

You can get rid of it in different ways on the mongo console. In this case we have two splines, one to keep and another to erase.

```js
var bone = db.bones.findOne({ _id: ObjectId("507ea06bd646a40002000759") })
bone.splines = [bone.splines[0] ];
db.bones.save(a);
```

How did we get into having this null record anyway? See [https://jira.mongodb.org/browse/SERVER-831](https://jira.mongodb.org/browse/SERVER-831) and [https://github.com/mongoid/mongoid/issues/2545](https://github.com/mongoid/mongoid/issues/2545).
