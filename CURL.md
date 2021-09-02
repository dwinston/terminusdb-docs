# CURL

Some CURL examples to make things easier for people building clients in various languages.

# Ping

Ping the server to see if it is alive

```bash
curl -X GET "http://127.0.0.1:6363/api/ok" -u "admin:root"
```

# Connect

```bash
curl -X GET "http://127.0.0.1:6363/api/" -u "admin:root"  -H "Content-Type: application/json"
```

# Create DB

```bash
curl -X POST "http://127.0.0.1:6363/api/db/admin/TEST_DB" -u "admin:root" -d '{ "comment" : "yo", "label" : "TEST_DB" }'  -H "Content-Type: application/json"
```

# Delete DB

```bash
curl -X DELETE "http://127.0.0.1:6363/api/db/admin/TEST_DB" -u "admin:root" 
```

# Get Prefixes

```bash
curl -X GET "http://127.0.0.1:6363/api/prefixes/admin/movie_graph" -u "admin:root"  -H "Content-Type: application/json"
```

# Get Version

```bash
curl -X GET "http://127.0.0.1:6363/api/info" -u "admin:root"  -H "Content-Type: application/json"
```

# Create Branch

```bash
curl -X POST "http://127.0.0.1:6363/api/branch/admin/foo/local/branch/bar" -u "admin:root" -d '{"origin" : "admin/foo/local/branch/main"}'  -H "Content-Type: application/json"
```

# Delete Branch

```bash
curl -X DELETE "http://127.0.0.1:6363/api/branch/admin/foo/local/branch/bar" -d '{}' -u "admin:root"  -H "Content-Type: application/json"
```

# Test WOQL multi-error response

```bash
curl -X POST "http://127.0.0.1:6363/api/woql/admin/test_schema" -u "admin:root" -d '{ 
  "all_witnesses" : true,
  "query" : {
  "@type":"And",
  "and": [
    {
      "@type":"QueryListElement",
      "index": {"@type":"xsd:integer", "@value":0},
      "query": {
	"@type":"AddTriple",
	"object":"scm:BS",
	"predicate":"rdf:type",
	"subject":"doc:test_subject"
      }
    },
    {
      "@type":"QueryListElement",
      "index": {"@type":"xsd:integer", "@value":1},
      "query": {
	"@type":"AddTriple",
	"object": {"@type":"xsd:integer", "@value":"asdf"},
	"predicate":"rdf:label",
	"subject":"doc:test_subject"
      }
    }
  ]
}}'  -H "Content-Type: application/json"
```

# Optimize

## System

```bash
curl -X POST "http://127.0.0.1:6363/api/optimize/_system" -u "admin:root" 
```
## Meta

```bash
curl -X POST "http://127.0.0.1:6363/api/optimize/admin/foo/_meta" -d '{}' -u "admin:root"  -H "Content-Type: application/json"
```

## Commit

```bash
curl -X POST "http://127.0.0.1:6363/api/optimize/admin/foo/local/_commits" -d '{}' -u "admin:root"  -H "Content-Type: application/json"
```

## Branch

```bash
curl -X POST "http://127.0.0.1:6363/api/optimize/admin/foo/local/branch/main" -d '{}' -u "admin:root"  -H "Content-Type: application/json"
```

# Clone

Creates a clone db from a remote

```bash
# Create DB
curl -X POST "http://127.0.0.1:6363/api/db/admin/TEST_DB" -u "admin:root" -d '{ "comment" : "yo", "label" : "TEST_DB" }'  -H "Content-Type: application/json"

# Clone DB
curl -X POST "http://127.0.0.1:6363/api/squash/admin/foo" -d '{ "comment" : "foo", "remote_url" : "http://127.0.0.1:6363/admin/TEST_DB", "label" : "foo", "commit_info" : { "author" : "me", "message" : "yo"}}}' -u "admin:root"  -H "Content-Type: application/json"
```

# Squash

Creates the new layer but does not put it anywhere (should use reset to afix it).

```bash
curl -X POST "http://127.0.0.1:6363/api/squash/admin/foo/local/branch/main" -d '{ "commit_info" : { "author" : "me", "message" : "yo"}}}' -u "admin:root"  -H "Content-Type: application/json"
```

*Returns:*

```javascript
{"@type" : "api:SquashResponse",
 "api:commit" : Commit,
 "api:old_commit" : Old_Commit,
 "api:status" : "api:success"}
```

# Reset

You will need to fill in COMMIT with a valid commit descriptor (for instance one return from squash)

```bash
curl -X POST "http://127.0.0.1:6363/api/reset/admin/foo/local/branch/main" -d '{ "commit_descriptor" : COMMIT}' -u "admin:root"  -H "Content-Type: application/json"
```

# Rebase

Rebase a branch on a path

```bash
curl -X POST "http://127.0.0.1:6363/api/rebase/admin/foo/local/branch/main" -d '{ "author" : "gavin@terminusdb.com", "rebase_from" : "admin/foo/local/branch/other" }' -u "admin:root"  -H "Content-Type: application/json"
```

# Document intface examples

All these examples are written against a hypothetical database called 'admin/moo'.

## submit a completely new schema, replacing your existing schema:

```jsx
cat /tmp/testschema.json|curl -X POST -k 'https://localhost:6363/api/document/admin/moo?graph_type=schema&author=me&message=hallo&full_replace=true' --data-binary @- -H 'Content-Type: application/json'
```

this example assumes you have a file at '/tmp/testschema.json' containing a schema. 

## submit a bunch of data into the instance graph

```jsx
how to make a closed captions botcat /tmp/testsdata.json|curl -X POST -k 'https://localhost:6363/api/document/admin/moo?author=me&message=hallo' --data-binary @- -H 'Content-Type: application/json'
```

this example assumes you have a file at '/tmp/testdata.json' containing data that matches the current schema.

## Get a list of instance documents:

```jsx
curl -k 'https://localhost:6363/api/document/admin/moo'
```

Note that we don't specify `graph_type`. We could also explicitely request `graph_type` instance though and get the same result:

```jsx
curl -k 'https://localhost:6363/api/document/admin/moo?graph_type=instance'
```

## Get a list of instance documents of a particular type:

```jsx
curl -k 'https://localhost:6363/api/document/admin/moo?type=Person'
```

## Query for a particular instance document by id:

```jsx
curl -k 'https://localhost:6363/api/document/admin/moo?graph_type=instance?id=Person_Robin_1995-09-29'
```

## Get a list of instance documents, skipping the first 3 and retrieving 5 more

```jsx
curl -k 'https://localhost:6363/api/document/admin/moo?skip=3&count=5'
```

## Get a list of instance documents, with each json object on its own line

```jsx
curl -k 'https://localhost:6363/api/document/admin/moo?minimized=true'
```

## Get a list of instance documents, as a json list instead of a stream

```jsx
curl -k 'https://localhost:6363/api/document/admin/moo?as_list=true'
```

## Delete a single object

```jsx
curl -X DELETE -k 'https://localhost:6363/api/document/admin/moo?uthor=me&message=blah&id=Person_1adfe57f9a2285da051445a3cf6056ef06dc1b7a'
```
