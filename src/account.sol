pragma solidity ^0.4.24;


/**
 * @title Account
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Contract for each MIX account.
 */
contract Account {

    /**
     * @dev Controller of the account.
     */
    address controller;

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
    function setController(address newController) external isController {
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
    function sendData(address to, bytes data) external payable isController {
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
