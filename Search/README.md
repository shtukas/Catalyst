Each subsystem implements its own searching capabilities, Search is the aggregator.

"Implementing the search interface" means that each subystem is able to return an array of `SearchResult`s

```
SearchResult {
	"subsystem"   : String
	"description" : String
	"uniqueId"    : String
}
```

- subsystem: name of the subsystem
- description: Description of the entity matched
- uniqueId: Unique identifier of the entity matched (semantically valid inside the corresponding subsystem)
