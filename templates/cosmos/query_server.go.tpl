;; go
package keeper

import (
	"context"

	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/sonr-io/sonr/x/{{_file_name_}}/types"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type queryServer struct {
	Keeper
}

// NewQueryServerImpl returns an implementation of the {{_camel_case_file_}} QueryServer interface
// for the provided Keeper.
func NewQueryServerImpl(keeper Keeper) types.QueryServer {
	return &queryServer{Keeper: keeper}
}

var _ types.QueryServer = queryServer{}

// {{_variable_}} implements types.QueryServer
func (k queryServer) {{_variable_}}(goCtx context.Context, req *types.Query{{_variable_}}Request) (*types.Query{{_variable_}}Response, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}

	ctx := sdk.UnwrapSDKContext(goCtx)

	{{_cursor_}}

	return &types.Query{{_variable_}}Response{}, nil
}
