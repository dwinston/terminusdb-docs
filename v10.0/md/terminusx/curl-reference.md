# Curl Examples

> **On this page:** Examples using [curl](https://curl.se/) to access the document interface.

The example commands below refer to a team `exampleteam` with a data product
`exampledb`.

[Get your API key](terminusx/get-your-api-key) to use TerminusX. The string
should be exported with:

```shell
export TERMINUSDB_ACCESS_TOKEN='...'
```

To keep the commands short, we also use an environment variable for the URL base
(host plus any route prefix). Here is an example:

```shell
export TERMINUSDB_BASE='https://cloud-dev.dcm.ist/exampleteam'
```

### Submit a new schema, replacing the existing schema

Use a hypothetical JSON file `exampleschema.json` containing a schema.

```shell

cat exampleschema.json | \
curl -X POST \
  "$TERMINUSDB_BASE/api/document/Something/exampledb?graph_type=schema&author=me&message=hallo&full_replace=true" \
  -H "Authorization: Bearer $TERMINUSDB_ACCESS_TOKEN" \
  -H 'Content-Type: application/json' \
  --data-binary @-


```

### Submit data into the instance graph

<!-- Removed: How to make a closed captions bot -->

```shell

cat exampledata.json | \
curl -X POST \
  "$TERMINUSDB_BASE/api/document/exampleteam/exampledb?author=me&message=hallo" \
  -H "Authorization: Bearer $TERMINUSDB_ACCESS_TOKEN" \
  -H 'Content-Type: application/json' \
  --data-binary @-


```

### Get a list of instance documents

Note the `graph_type` is not specified in the first example. Explicitly requesting the `graph_type` instance, in the second example, provides the same result.  

```shell

curl "$TERMINUSDB_BASE/api/document/exampleteam/exampledb" \
  -H "Authorization: Bearer $TERMINUSDB_ACCESS_TOKEN"


```

```shell

curl "$TERMINUSDB_BASE/api/document/exampleteam/exampledb?graph_type=instance" \
  -H "Authorization: Bearer $TERMINUSDB_ACCESS_TOKEN"


```

### Get a list of instance documents of a particular type

```shell

curl "$TERMINUSDB_BASE/api/document/exampleteam/exampledb?type=Person" \
  -H "Authorization: Bearer $TERMINUSDB_ACCESS_TOKEN"


```

### Get a particular instance document by id

```shell

curl "$TERMINUSDB_BASE/api/document/exampleteam/exampledb?graph_type=instance?id=Person_Robin_1995-09-29" \
  -H "Authorization: Bearer $TERMINUSDB_ACCESS_TOKEN"


```

### Get a list of instance documents, skipping the first 3 and retrieving 5 more

```shell

curl "$TERMINUSDB_BASE/api/document/exampleteam/exampledb?skip=3&count=5" \
  -H "Authorization: Bearer $TERMINUSDB_ACCESS_TOKEN"


```

### Get a list of instance documents, as a JSON list instead of a stream

```shell

curl "$TERMINUSDB_BASE/api/document/exampleteam/exampledb?as_list=true" \
  -H "Authorization: Bearer $TERMINUSDB_ACCESS_TOKEN"


```

### Delete a single object

```shell

curl -X DELETE \
  "$TERMINUSDB_BASE/api/document/exampleteam/exampledb?uthor=me&message=blah&id=Person_1adfe57f9a2285da051445a3cf6056ef06dc1b7a" \
  -H "Authorization: Bearer $TERMINUSDB_ACCESS_TOKEN"


```
