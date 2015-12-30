# sis_ruby

A Ruby client to talk to a SIS server (https://github.com/sis-cmdb/sis-api).

Currently only the v1.1 API is supported.

Initial commit represents work by Neel Goyal, formerly at Verisign,
and Keith Bennett, currently at Verisign (http://www.verisign.com/).


## Usage

Example code:

```
require 'sis_ruby'

# Create a client
client = SisRuby::Client.new(sis_server_url)

# Get the host information endpoint
hosts = client.entities('host')

# Use all possible Params options to list records of a given entity:
params = SisRuby::Params.new.sort('hostname').offset(9000).limit(2).fields('hostname', 'environment') 
records = hosts.list(params)

# Get record counts:
puts "Total host count is #{hosts.count}"
puts "Total qa host count is  #{hosts.count('environment' => 'qa')}"

# Get up to 10 hooks
hook_list = client.hooks.list(SisRuby::Params.new.limit(10))

# Get 1 schema
schema_list = client.schemas.list(SisRuby::Params.new.limit(1)).first

# Hiera Entry Creation
hiera_entry = client.hiera.create({ 'name' => 'entry', 'hieradata' => { 'key1' => 'value1' }});

# Entity Deletion: Delete the entity of type 'entity_name' with id 'foo':
was_deleted = client.entities('entity_name').delete('foo');
```

## Client Initialization

The client constructor takes the following parameters:
 
* (required) a URL indicating the base URL of the SIS endpoints
* (optional) a hash containing neither, one, or both of:
  * **:auth_token** - an authorization token field to be sent in the `x-auth-token` header
  * **:api_version** - a version string to use in the request URL's instead of the default API version

```
client = SisRuby::Client.new(sis_server_url)
client = SisRuby::Client.new(sis_server_url, auth_token: auth_token)
```

## Client Authentication

The client may also acquire and use a temporary token to use against the SIS endpoint 
via the `authenticate` method.  Below are examples:

```
# This method will raise an SisRuby::Client::AuthenticationError if authentication fails.
token = client.authenticate(userid, password)

# You can also combine the client creation and authentication into a single expression
# since the authenticate method returns the client:
client = SisRuby::Client.new(sis_server_url).authenticate(userid, password)
```

Although `authenticate` returns the token, there is no need to save it;
it is stored in the client instance for subsequent requests.

## Entity, Hook, Schema, and Hiera Methods

The object returned by `client.hooks`, `client.schemas`, `client.hiera`, and 
`client.entities(entity_name)` all interact with the appropriate endpoints
and expose the following interface:


### list(query)

This maps to a GET `/` request against the appropriate endpoint for the default or specified API version.

List parameters can be specified in the form of any object responding to
`to_hash` and returning a hash (including, of course, a `Hash`).

Values in the hash can contain:

* **sort** - field name(s) on which to sort the records, precede fieldname with `-` for descending
* **limit** - limit the result set size to the specified number of records
* **fields** - only return the fields passed to this method; however:
  * currently there is a bug that results in array type fields being returned even if they
are not included in the field list
  * the _id field will always be returned even if it is not specified
* **offset** - the offset into the sorted results at which to start adding records to the result set
(Note: offset is not reliable unless a sort order is specified; there is no default sort order
and the random order may change from call to call.

For your convenience, a `Params` class has been provided with chainable methods (see code example).

Also, there is a `count` method that will return the total record count. If passed a filter, it will
return the count of records that meet the filter criteria.

An array of hashes is returned on success.  For your convenience, there is also a
`list_as_openstructs` method that returns each record as an `OpenStruct` instance for easier access.
OpenStruct instances allow you to call methods whose names correspond to the original hash's keys,
e.g. `host.site` instead of `host['site']`.
This approach is not recommended for large numbers of records, as it requires more memory and processing.


### get(id)

This maps to a GET `/id` request against the approprivate endpoint for the default or specified API version.

* id : a string representing the ID of the object to receive.  For schemas, hooks, and hiera, this is the `name`.  
For entities, it is the `_id`.

A single hash representing the object is returned on success.


### create(obj)

This maps to a POST `/` request against the appropriate endpoint for the default or specified API version.

* obj : a valid Hash conforming to the endpoint specification

The created object as a hash is returned on success.


### update(obj)

This maps to a PUT '/' request against the appropriate endpoint for the default or specified API version.

* obj : a valid hash conforming to the endpoint specification.  Typically retrieved from `list` or `get`.

The updated hash representing the object is returned on success.


### delete(obj)

This maps to a DELETE '/id' request against the appropriate endpoint for the default or specified API version.

* obj : either a string id or an object retrieved from `list` or `get`

The boolean `true` is returned on success.


## Error handling

An instance of `SisRuby::Client` will raise an exception if an HTTP request returns a status code above and including 400.


## Running the Tests

Test code is divided into different top-level directories:

### `spec`
 
These are tests not requiring a SIS server.

### `spec_reading`
 
These are tests requiring a SIS server containing a 'host' entity populated with records

### `spec_writing`
 
These are tests requiring a SIS server that can be used for writing; for these
you'll probably want to set up a local server.  Instructions for this are at 
https://github.com/sis-cmdb/sis-api#building-and-testing.

If the tests should ever fail and the data base is not correctly restored to
its original empty state, you can delete the Mongo data 
by running the Mongo shell ('mongo') and issuing the following commands:

```
use test
db.dropDatabase();
```

To verify the user id and password, you can issue the following command, replacing 'test' and
'abc123' with the real user id and password:

```
curl -D- -u test:abc123 -X POST -H "Content-Type: application/json" http://localhost:3000/api/v1.1/users/auth_token
```
