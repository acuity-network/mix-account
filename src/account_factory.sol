pragma solidity ^0.4.24;

import "./account.sol";


/**
 * @title AccountFactory
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Deploys Account.
 */
contract AccountFactory {

    function deploy() external returns (Account) {
        return new Account(msg.sender);
    }
}
