pragma solidity ^0.5.9;

import "mix-token/MixToken.sol";
import "./ERC165.sol";
import "./ERC1155TokenReceiver.sol";


/**
 * @title MixAccount
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Contract for each MIX account.
 */
contract MixAccount is MixTokenReceiverInterface, ERC165, ERC1155TokenReceiver {

    /**
     * @dev Controller of the account.
     */
    address payable controller;

    /**
     * @dev The controller has been set.
     * @param controller The address that controls this account.
     */
    event SetController(address controller);

    /**
     * @dev MIX has been received.
     * @param from Address that sent the MIX.
     * @param value Amount of MIX received.
     */
    event Receive(address from, uint value);

    /**
     * @dev A token has been received.
     * @param from Address that sent the token.
     * @param value Amount of the token received.
     * @param tokenContract The ERC223 contract that manages the token.
     */
    event ReceiveToken(address from, uint value, address tokenContract);

    /**
     * @dev An ERC1155 token has been received.
     * @param operator The address which initiated the transfer.
     * @param from The address which previously owned the token.
     * @param id The ID of the token being transferred.
     * @param value Amount of the token received.
     */
    event ReceiveERC1155Token(address operator, address from, uint256 id, uint256 value);

    /**
     * @dev Revert if the controller of the account is not the sender.
     */
    modifier isController() {
        require (controller == msg.sender, "Not controller.");
        _;
    }

    /**
     * @dev Revert if no value is sent.
     */
    modifier hasValue() {
        require (msg.value > 0, "No value.");
        _;
    }

    /**
     * @dev Constructor.
     */
    constructor() public {
        // Store the controller.
        controller = msg.sender;
        // Log the event.
        emit SetController(controller);
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
     * @dev Get which address controls this account.
     * @return Controller of the account.
     */
    function getController() external view returns (address) {
        return controller;
    }

    /**
     * @dev Send MIX to an address.
     * @param to Address to receive the MIX.
     */
    function sendMix(address to) external payable hasValue isController {
        // Send the MIX.
        uint value = msg.value;
        bool success;
        assembly {
            success := call(not(0), to, value, 0, 0, 0, 0)
        }
        // Check the result.
        require (success, "Failed to send MIX.");
    }

    /**
     * @dev Perform a call.
     * @param to Address to receive the call.
     * @param data The calldata.
     */
    function sendData(address to, bytes calldata data) external payable isController {
        // Send the data.
        uint value = msg.value;
        bytes memory _data = data;
        bool success;
        assembly {
            success := call(not(0), to, value, add(_data, 0x20), mload(_data), 0, 0)
        }
        // Check the result.
        require (success, "Failed to send data.");
    }

    /**
     * @dev Fallback function.
     */
    function() external payable hasValue {
        // Log the event.
        if (msg.sender != controller) {
          emit Receive(msg.sender, msg.value);
        }
    }

    /**
     * @dev MixToken fallback function.
     */
    function receiveMixToken(address from, uint value, bytes calldata) external returns (bytes4) {
        if (from != controller) {
            // Log the event.
            emit ReceiveToken(from, value, msg.sender);
        }
        return 0xf2e0ed8f;
    }

    /**
     * @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeTransferFrom` after the balance has been updated.
     * @param operator The address which initiated the transfer (i.e. msg.sender).
     * @param from The address which previously owned the token.
     * @param id The ID of the token being transferred.
     * @param value The amount of tokens being transferred.
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     */
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata) external returns (bytes4) {
        if (from != controller) {
            // Log the event.
            emit ReceiveERC1155Token(operator, from, id, value);
        }
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    /**
     * @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeBatchTransferFrom` after the balances have been updated.
     * @param operator The address which initiated the batch transfer (i.e. msg.sender).
     * @param from The address which previously owned the token.
     * @param ids An array containing ids of each token being transferred (order and length must match values array).
     * @param values An array containing amounts of each token being transferred (order and length must match ids array).
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     */
    function onERC1155BatchReceived(address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata) external returns (bytes4) {
        if (from != controller) {
            uint count = ids.length;
            for (uint i = 0; i < count; i++) {
                // Log the event.
                emit ReceiveERC1155Token(operator, from, ids[i], values[i]);
            }
        }
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
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

    /**
     * @dev Send all MIX to the controller.
     */
    function withdraw() external isController {
        // Transfer the balance to the controller.
        address _controller = controller;
        uint value = address(this).balance;
        bool success;
        assembly {
            success := call(not(0), _controller, value, 0, 0, 0, 0)
        }
        require (success, "Failed to withdraw MIX.");
    }

    /**
     * @dev Destroy the contract and return any funds to the controller.
     */
    function destroy() external isController {
        selfdestruct(controller);
    }

}
