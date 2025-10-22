;; proto
syntax = "proto3";
package sonr.{{_file_name_}}.v1;

option go_package = "github.com/sonr-io/sonr/x/{{_file_name_}}/types";

import "gogoproto/gogo.proto";
import "google/api/annotations.proto";
import "cosmos/base/query/v1beta1/pagination.proto";
import "cosmos/query/v1/query.proto";

// Query defines the gRPC querier service
service Query {
  // {{_variable_}} queries the {{_variable_}}
  rpc {{_variable_}}(Query{{_variable_}}Request) returns (Query{{_variable_}}Response) {
    option (cosmos.query.v1.module_query_safe) = true;
    option (google.api.http).get = "/sonr/{{_file_name_}}/v1/{{_variable_}}";
  }
}

// Query{{_variable_}}Request is the request type for the Query/{{_variable_}} RPC method
message Query{{_variable_}}Request {
  {{_cursor_}}
}

// Query{{_variable_}}Response is the response type for the Query/{{_variable_}} RPC method
message Query{{_variable_}}Response {

}
