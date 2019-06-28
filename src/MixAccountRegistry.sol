pragma solidity ^0.5.9;

import "./MixAccount.sol";


/**
 * @title MixAccountRegistry
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Allows controllers to store a record of which account they control.
 */
contract MixAccountRegistry {

    /**
     * @dev Mapping of controller to account.
     */
    mapping (address => MixAccount) controllerAccount;

    function set(MixAccount account) external {
        controllerAccount[msg.sender] = account;
    }

    function get(address controller) external view returns (MixAccount) {
        return controllerAccount[controller];
    }

}
