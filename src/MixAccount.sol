pragma solidity ^0.5.11;

import "./ERC165.sol";
import "./MixAccountInterface.sol";
import "./ERC1155TokenReceiver.sol";


/**
 * @title MixAccount
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Contract for each MIX account.
 */
contract MixAccount is ERC165, MixAccountInterface, ERC1155TokenReceiver {

    /**
     * @dev Controller of the account.
     */
    address payable controller;

    /**
     * @dev Revert if the controller of the account is not the sender.
     */
    modifier isController() {
        require (controller == msg.sender);
        _;
    }

    /**
     * @dev Revert if no value is sent.
     */
    modifier hasValue() {
        require (msg.value > 0);
        _;
    }

    /**
     * @dev Constructor.
     */
    constructor() public {
        // Store the controller.
        controller = msg.sender;
        // Log the event.
        // Don't pass controller state variable or deployment will revert.
        emit SetController(msg.sender);
    }

    /**
     * @dev Set which address controls this account.
     * @param newController New controller of the account.
     */
    function setController(address payable newController) external isController {
        // Store the controller.
        controller = newController;
        // Log the event.
        emit SetController(newController);
    }

    /**
     * @dev Log call failure with return data.
     */
    function logCallFailure() internal {
        uint size;
        assembly {
            size := returndatasize
        }
        bytes memory returnData = new bytes(size);
        assembly {
            returndatacopy(add(returnData, 0x20), 0, size)
        }
        emit CallFailed(returnData);
    }

    /**
     * @dev Send MIX to an address.
     * @param to Address to receive the MIX.
     */
    function sendMix(address to) external payable isController returns (bool success) {
        // Send the MIX.
        uint value = msg.value;
        assembly {
            success := call(not(0), to, value, 0, 0, 0, 0)
        }
        // Check if it succeeded.
        if (!success) {
            logCallFailure();
        }
    }

    /**
     * @dev Perform a call.
     * @param to Address to receive the call.
     * @param data The calldata.
     */
    function sendData(address to, bytes calldata data) external payable isController returns (bool success) {
        // Send the data.
        uint value = msg.value;
        bytes memory _data = data;
        assembly {
            success := call(not(0), to, value, add(_data, 0x20), mload(_data), 0, 0)
        }
        // Check if it succeeded.
        if (!success) {
            logCallFailure();
        }
    }

    /**
     * @dev Send all MIX to the controller.
     */
    function withdraw() external isController {
        // Transfer the balance to the controller.
        address _controller = controller;
        uint value = address(this).balance;
        assembly {
            let success := call(not(0), _controller, value, 0, 0, 0, 0)
            if iszero(success) {
                revert(0, 0)
            }
        }
    }

    /**
     * @dev Destroy the contract and return any funds to the controller.
     */
    function destroy() external isController {
        selfdestruct(controller);
    }

    /**
     * @dev Fallback function.
     */
    function() external payable hasValue {
        // Check call didn't come from the controller.
        if (msg.sender != controller) {
            // Log the event.
            emit ReceiveMix(msg.sender, msg.value);
        }
    }

    /**
     * @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeTransferFrom` after the balance has been updated.
     * @param operator The address which initiated the transfer (i.e. msg.sender).
     * @param from The address which previously owned the token.
     * @param id The ID of the token being transferred.
     * @param value The amount of tokens being transferred.
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     */
    function onERC1155Received(address operator, address from, uint id, uint value, bytes calldata) external returns (bytes4) {
        // Check call didn't come from the controller.
        if (from != controller) {
            // Log the event.
            emit ReceiveERC1155Token(from, msg.sender, id, value, operator);
        }
        return hex"f23a6e61";
    }

    /**
     * @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeBatchTransferFrom` after the balances have been updated.
     * @param operator The address which initiated the batch transfer (i.e. msg.sender).
     * @param from The address which previously owned the token.
     * @param ids An array containing ids of each token being transferred (order and length must match values array).
     * @param values An array containing amounts of each token being transferred (order and length must match ids array).
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     */
    function onERC1155BatchReceived(address operator, address from, uint[] calldata ids, uint[] calldata values, bytes calldata) external returns (bytes4) {
        // Check call didn't come from the controller.
        if (from != controller) {
            uint count = ids.length;
            for (uint i = 0; i < count; i++) {
                // Log the event.
                emit ReceiveERC1155Token(from, msg.sender, ids[i], values[i], operator);
            }
        }
        return hex"bc197c81";
    }

    /**
     * @dev Interface identification is specified in ERC-165.
     * @param interfaceID The interface identifier, as specified in ERC-165.
     * @return true if the contract implements interfaceID.
     */
    function supportsInterface(bytes4 interfaceID) external view returns (bool) {
        if (interfaceID == 0x01ffc9a7 ||
            interfaceID == 0x4e2312e0)
        {
            return true;
        }
        return false;
    }

}
