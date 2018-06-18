pragma solidity ^0.4.24;

/**
 * @title Account
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Contract for each MIX account.
 */
contract Account {

    /**
     * @dev Owner of the account.
     */
    address owner;

    /**
     * @dev Set the owner of the account.
     * @param owner The owner of the account.
     */
    event SetOwner(address indexed owner);

    /**
     * @dev A send has been made.
     * @param receiver Account that received the funds.
     * @param value Amount sent.
     */
    event Send(address indexed receiver, uint value);

    /**
     * @dev A receive has been made.
     * @param sender Account that send the receive.
     * @param value Amount received.
     */
    event Receive(address indexed sender, uint value);

    /**
     * @dev Revert if the owner of the item is not the message sender.
     */
    modifier isOwner() {
        require (owner == msg.sender);
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
     * @param _owner Account controlling this account.
     */
    constructor(address _owner) public {
        // Store the owner.
        owner = _owner;
        // Log the event.
        emit SetOwner(_owner);
    }

    /**
     * @dev Change which address owns this account.
     * @param newOwner New owner of the account.
     */
    function changeOwner(address newOwner) external isOwner {
        owner = newOwner;
        // Log the event.
        emit SetOwner(newOwner);
    }

    /**
     * @dev Forward MIX to an address.
     * @param receiver Address to receive the MIX.
     */
    function sendMix(address receiver) external payable isOwner hasValue {
        // Send the value to the receiver.
        uint value = msg.value;
        // Log the event.
        emit Send(receiver, value);
        assembly {
            let success := call(not(0), receiver, value, 0, 0, 0, 0)
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
     * @param receiver Address to receive the call.
     * @param data The calldata.
     * @param returnLength Maximum length of the return data.
     */
    function callH(address receiver, bytes data, uint returnLength) external payable isOwner {
        uint value = msg.value;
        // Log if MIX has been sent.
        if (value > 0) {
          emit Send(receiver, value);
        }
        bytes memory _data = data;
        assembly {
            let returnedData := mload(0x40)
            let success := call(not(0), receiver, value, add(_data, 0x20), mload(_data), returnedData, returnLength)
            if iszero(success) {
                invalid()
            }
            return(returnedData, returnLength)
        }
    }

    /**
     * @dev Perform a call on Byzantium.
     * @param receiver Address to receive the call.
     * @param data The calldata.
     */
    function callB(address receiver, bytes data) external payable isOwner {
        uint value = msg.value;
        // Log if MIX has been sent.
        if (value > 0) {
          emit Send(receiver, value);
        }
        bytes memory _data = data;
        assembly {
            let success := call(not(0), receiver, value, add(_data, 0x20), mload(_data), 0, 0)
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
     * @param receiver Address to receive the call.
     * @param data The calldata.
     */
    function staticCall(address receiver, bytes data) external view isOwner {
        bytes memory _data = data;
        assembly {
            let success := staticcall(not(0), receiver, add(_data, 0x20), mload(_data), 0, 0)
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
     * @dev Send all MIX to the owner.
     */
    function withdraw() external isOwner {
        // Transfer the balance to the owner.
        address _owner = owner;
        uint _value = address(this).balance;
        assembly {
            let success := call(not(0), _owner, _value, 0, 0, 0, 0)
            if iszero(success) {
                let returnedData := mload(0x40)
                // This will be an invalid instruction on Homestead and cause the call to revert.
                returndatacopy(returnedData, 0, returndatasize)
                revert(returnedData, returndatasize)
            }
        }
    }

    /**
     * @dev Destroy the contract and return any funds to the owner.
     */
    function destroy() external isOwner {
        selfdestruct(owner);
    }

}
