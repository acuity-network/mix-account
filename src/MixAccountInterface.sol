pragma solidity ^0.5.10;


/**
 * @title MixAccountInterface
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Interface for implementing a MIX account contract.
 */
interface MixAccountInterface /* is ERC1155TokenReceiver */ {

    /**
     * @dev The controller has been set.
     * @param controller The address that controls this account.
     */
    event SetController(address controller);

    /**
     * @dev A call has failed.
     * @param returnData Data returned from the call.
     */
    event CallFailed(bytes returnData);

    /**
     * @dev MIX has been received.
     * @param from Address that sent the MIX.
     * @param value Amount of MIX received.
     */
    event ReceiveMix(address indexed from, uint value);

    /**
     * @dev Set which address controls this account.
     * @param newController New controller of the account.
     */
    function setController(address payable newController) external;

    /**
     * @dev Send MIX to an address.
     * @param to Address to receive the MIX.
     */
    function sendMix(address to) external payable returns (bool success);

    /**
     * @dev Perform a call.
     * @param to Address to receive the call.
     * @param data The calldata.
     */
    function sendData(address to, bytes calldata data) external payable returns (bool success);

    /**
     * @dev Send all MIX to the controller.
     */
    function withdraw() external;

    /**
     * @dev Destroy the contract and return any funds to the controller.
     */
    function destroy() external;

    /**
     * @dev Fallback function.
     */
    function() external payable;

}
