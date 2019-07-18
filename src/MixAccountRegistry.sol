pragma solidity ^0.5.10;

import "./MixAccount.sol";


/**
 * @title MixAccountRegistry
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Enables controllers to store a record of which account they control.
 */
contract MixAccountRegistry {

    /**
     * @dev Mapping of controller to account.
     */
    mapping (address => MixAccount) controllerAccount;

    /**
     * @dev Revert if the controller does not have an account.
     */
    modifier accountExists(address controller) {
        require (controllerAccount[controller] != MixAccount(0), "Account not found.");
        _;
    }

    function set(MixAccount account) external {
        controllerAccount[msg.sender] = account;
    }

    function get(address controller) external view accountExists(controller) returns (MixAccount) {
        return controllerAccount[controller];
    }

}
