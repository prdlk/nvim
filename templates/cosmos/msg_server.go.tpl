;; go
package keeper

import (
	"context"

	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/sonr-io/sonr/x/{{_file_name_}}/types"
)

type msgServer struct {
	Keeper
}

// NewMsgServerImpl returns an implementation of the {{_camel_case_file_}} MsgServer interface
// for the provided Keeper.
func NewMsgServerImpl(keeper Keeper) types.MsgServer {
	return &msgServer{Keeper: keeper}
}

var _ types.MsgServer = msgServer{}

// {{_variable_}} implements types.MsgServer
func (k msgServer) {{_variable_}}(goCtx context.Context, msg *types.Msg{{_variable_}}) (*types.Msg{{_variable_}}Response, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	// Validate message
	if err := msg.ValidateBasic(); err != nil {
		return nil, err
	}

	{{_cursor_}}

	// Emit event
	ctx.EventManager().EmitEvent(
		sdk.NewEvent(
			types.EventType{{_variable_}},
			sdk.NewAttribute(types.AttributeKeyCreator, msg.Creator),
		),
	)

	return &types.Msg{{_variable_}}Response{}, nil
}
