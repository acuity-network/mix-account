pragma solidity ^0.5.9;

import "./MixAccount.sol";


/**
 * @title MixAccountRegistry
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Allows controllers to store a record of which accounts they control.
 */
contract MixAccountRegistry {

    /**
     * @dev Mapping of controller to array of account contracts.
     */
    mapping (address => MixAccount[]) controllerAccounts;

    modifier senderIsController(MixAccount account) {
        require (account.getController() == msg.sender, "Sender is not controller.");
        _;
    }

    modifier accountNotAdded(MixAccount account) {
        uint i = getAccountIndex(account);
        require (i == controllerAccounts[msg.sender].length, "Account already added.");
        _;
    }

    function getAccountIndex(MixAccount account) internal returns (uint i) {
        MixAccount[] storage accounts = controllerAccounts[msg.sender];
        for (i = 0; i < accounts.length; i++) {
            if (accounts[i] == account) {
                break;
            }
        }
    }

    function addAccount(MixAccount account) external
        senderIsController(account)
        accountNotAdded(account)
    {
        controllerAccounts[msg.sender].push(account);
    }

    function removeAccount(MixAccount account) external {
        MixAccount[] storage accounts = controllerAccounts[msg.sender];
        uint i = getAccountIndex(account);
        require (i != accounts.length, "Account not found.");

        if (i != 0) {
            accounts[i] = accounts[accounts.length - 1];
        }
        controllerAccounts[msg.sender].pop();
    }

    function getAccounts() external view returns (MixAccount[] memory) {
        return controllerAccounts[msg.sender];
    }

}
