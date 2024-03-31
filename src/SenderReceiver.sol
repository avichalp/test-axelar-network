// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AxelarExecutable} from "axelar-gmp-sdk-solidity/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "axelar-gmp-sdk-solidity/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "axelar-gmp-sdk-solidity/interfaces/IAxelarGasService.sol";

contract SenderReceiver is AxelarExecutable {
    IAxelarGasService public immutable gasService;
    string public message;

    event Executed(string from);

    constructor(
        address gateway_,
        address gasService_
    ) AxelarExecutable(gateway_) {
        gasService = IAxelarGasService(gasService_);
    }

    function sendMessage(
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata message_
    ) external payable {
        bytes memory payload = abi.encode(message_);
        gasService.payNativeGasForContractCall{value: msg.value}(
            address(this),
            destinationChain,
            destinationAddress,
            payload,
            msg.sender
        );
        gateway.callContract(destinationChain, destinationAddress, payload);
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload_
    ) internal override {
        // we knew that we are expecting a string
        // because the type of message in sender is a string
        //message = abi.decode(payload_, (string));
        emit Executed(sourceAddress);
    }
}
