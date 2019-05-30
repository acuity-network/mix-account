pragma solidity ^0.5.7;

import "mix-token/MixToken.sol";
import "./IERC1155TokenReceiver.sol";


/**
 * @title Account
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Contract for each MIX account.
 */
contract Account is MixTokenReceiverInterface, IERC1155TokenReceiver {

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

    event ReceiveERC1155Token(address operator, address from, uint256 id, uint256 value);

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
     * @dev Send MIX to an address.
     * @param to Address to receive the MIX.
     */
    function sendMix(address to) external payable hasValue isController {
        uint value = msg.value;
        // Send the MIX.
        assembly {
            let success := call(not(0), to, value, 0, 0, 0, 0)
            if iszero(success) {
                revert(0, 0)
            }
        }
    }

    /**
     * @dev Perform a call.
     * @param to Address to receive the call.
     * @param data The calldata.
     */
    function sendData(address to, bytes calldata data) external payable isController {
        uint value = msg.value;
        // Send the call.
        bytes memory _data = data;
        assembly {
            let success := call(not(0), to, value, add(_data, 0x20), mload(_data), 0, 0)
            if iszero(success) {
                revert(0, 0)
            }
        }
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
        // Log the event.
        if (from != controller) {
            emit ReceiveToken(from, value, msg.sender);
        }
        return 0xf2e0ed8f;
     }

    /**
     * @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeTransferFrom` after the balance has been updated.
     * @param operator The address which called the `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param id The id of the token being transferred
     * @param value The amount of tokens being transferred
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    */
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata) external returns (bytes4) {
        // Log the event.
        if (from != controller) {
            emit ReceiveERC1155Token(operator, from, id, value);
        }
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    /**
     * @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeBatchTransferFrom` after the balances have been updated.
     * @param operator The address which called the `safeBatchTransferFrom` function
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred
     * @param values An array containing amounts of each token being transferred
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
    */
    function onERC1155BatchReceived(address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata) external returns (bytes4) {
        // Log the event.
        if (from != controller) {
            uint count = ids.length;
            for (uint i = 0; i < count; i++) {
                emit ReceiveERC1155Token(operator, from, ids[i], values[i]);
            }
        }
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
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

}
