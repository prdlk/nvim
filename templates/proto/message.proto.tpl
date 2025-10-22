;; proto
syntax = "proto3";
package sonr.{{_file_name_}}.v1;

option go_package = "github.com/sonr-io/sonr/x/{{_file_name_}}/types";

import "gogoproto/gogo.proto";
import "cosmos_proto/cosmos.proto";
import "amino/amino.proto";

// {{_variable_}} defines the {{_variable_}} message
message {{_variable_}} {
  option (gogoproto.equal) = true;
  option (amino.name) = "sonr/{{_file_name_}}/{{_variable_}}";

  {{_cursor_}}
}
