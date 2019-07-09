pragma solidity ^0.5.9;


/**
 * @title MixAccountInterface
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Interface for implementing a MIX account contract.
 */
interface MixAccountInterface /* is ERC165, MixTokenReceiverInterface, ERC1155TokenReceiver */ {

    /**
     * @dev Set which address controls this account.
     * @param newController New controller of the account.
     */
    function setController(address payable newController) external;

    /**
     * @dev Send MIX to an address.
     * @param to Address to receive the MIX.
     */
    function sendMix(address to) external payable;

    /**
     * @dev Perform a call.
     * @param to Address to receive the call.
     * @param data The calldata.
     */
    function sendData(address to, bytes calldata data) external payable;

    /**
     * @dev Fallback function.
     */
    function() external payable;

    /**
     * @dev Send all MIX to the controller.
     */
    function withdraw() external;

    /**
     * @dev Destroy the contract and return any funds to the controller.
     */
    function destroy() external;

}
