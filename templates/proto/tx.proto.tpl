;; proto
syntax = "proto3";
package sonr.{{_file_name_}}.v1;

option go_package = "github.com/sonr-io/sonr/x/{{_file_name_}}/types";

import "gogoproto/gogo.proto";
import "cosmos_proto/cosmos.proto";
import "cosmos/msg/v1/msg.proto";
import "amino/amino.proto";

// Msg defines the {{_file_name_}} Msg service
service Msg {
  option (cosmos.msg.v1.service) = true;

  // {{_variable_}} defines the {{_variable_}} RPC method
  rpc {{_variable_}}(Msg{{_variable_}}) returns (Msg{{_variable_}}Response);
}

// Msg{{_variable_}} defines the {{_variable_}} message
message Msg{{_variable_}} {
  option (cosmos.msg.v1.signer) = "creator";
  option (amino.name) = "sonr/{{_file_name_}}/{{_variable_}}";

  string creator = 1 [(cosmos_proto.scalar) = "cosmos.AddressString"];
  {{_cursor_}}
}

// Msg{{_variable_}}Response defines the {{_variable_}} response
message Msg{{_variable_}}Response {}
