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
    event SetController(address indexed controller);

    /**
     * @dev MIX has been sent.
     * @param to Address that received the MIX.
     * @param value Amount of MIX sent.
     */
    event Send(address indexed to, uint value);

    /**
     * @dev MIX has been received.
     * @param from Address that sent the MIX.
     * @param value Amount of MIX sent.
     */
    event Receive(address indexed from, uint value);

    /**
     * @dev Revert if the controller of the item is not the sender.
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
    function sendMix(address to) external payable isController hasValue {
        // Send the value to the to.
        uint value = msg.value;
        // Log the event.
        emit Send(to, value);
        assembly {
            let success := call(not(0), to, value, 0, 0, 0, 0)
            if iszero(success) {
                let returnedData := mload(0x40)
                // This will be an invalid instruction on Homestead and cause the call to revert.
                returndatacopy(returnedData, 0, returndatasize)
                revert(returnedData, returndatasize)
            }
        }
    }

    /**
     * @dev Perform a call on Homestead.
     * @param to Address to receive the call.
     * @param data The calldata.
     * @param returnLength Maximum length of the return data.
     */
    function callH(address to, bytes data, uint returnLength) external payable isController returns (bytes32) {
        uint value = msg.value;
        // Log if MIX has been sent.
        if (value > 0) {
          emit Send(to, value);
        }
        bytes memory _data = data;
        assembly {
            let returnedData := mload(0x40)
            let success := call(not(0), to, value, add(_data, 0x20), mload(_data), returnedData, returnLength)
            if iszero(success) {
                invalid()
            }
            return(returnedData, returnLength)
        }
    }

    /**
     * @dev Perform a call on Byzantium.
     * @param to Address to receive the call.
     * @param data The calldata.
     */
    function callB(address to, bytes data) external payable isController returns (bytes32) {
        uint value = msg.value;
        // Log if MIX has been sent.
        if (value > 0) {
          emit Send(to, value);
        }
        bytes memory _data = data;
        assembly {
            let success := call(not(0), to, value, add(_data, 0x20), mload(_data), 0, 0)
            let returnedData := mload(0x40)
            returndatacopy(returnedData, 0, returndatasize)
            if iszero(success) {
                revert(returnedData, returndatasize)
            }
            return(returnedData, returndatasize)
        }
    }

    /**
     * @dev Perform a staticcall.
     * @param to Address to receive the call.
     * @param data The calldata.
     */
    function staticCall(address to, bytes data) external view isController returns (bytes32) {
        bytes memory _data = data;
        assembly {
            let success := staticcall(not(0), to, add(_data, 0x20), mload(_data), 0, 0)
            let returnedData := mload(0x40)
            returndatacopy(returnedData, 0, returndatasize)
            if iszero(success) {
                revert(returnedData, returndatasize)
            }
            return(returnedData, returndatasize)
        }
    }

    /**
     * @dev Fallback function.
     */
    function() external payable hasValue {
        // Log the event.
        emit Receive(msg.sender, msg.value);
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
                let returnedData := mload(0x40)
                // This will be an invalid instruction on Homestead and cause the call to revert.
                returndatacopy(returnedData, 0, returndatasize)
                revert(returnedData, returndatasize)
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
