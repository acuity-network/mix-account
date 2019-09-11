pragma solidity ^0.5.11;


/**
 * @title MixAccountInterface
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Interface for implementing a MIX account contract.
 */
interface MixAccountInterface /* is ERC1155TokenReceiver, ERC165 */ {

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
     * @dev An ERC1155 token has been received.
     * @param from The address which previously owned the token.
     * @param tokenContract The ERC1155 contract that manages the token.
     * @param id The ID of the token being transferred.
     * @param value Amount of the token received.
     * @param operator The address which initiated the transfer.
     */
    event ReceiveERC1155Token(address indexed from, address indexed tokenContract, uint indexed id, uint value, address operator);

    /**
     * @dev Set which address controls this account.
     * @param newController New controller of the account.
     */
    function setController(address payable newController) external;

    /**
     * @dev Send a call, returning the result.
     * @param to Address to receive the call.
     * @param data The calldata.
     * @return success True if the call did not revert.
     * @return returnData Data returned from the call.
     */
    function sendCall(address to, bytes calldata data) external payable returns (bool success, bytes memory returnData);

    /**
     * @dev Send a call without returning the result.
     * @param to Address to receive the call.
     * @param data The calldata.
     */
    function sendCallNoReturn(address to, bytes calldata data) external payable;

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

contract MixAccountInterfaceId {
    function getInterfaceId() external pure returns (bytes4) {
        MixAccountInterface i;
        return i.setController.selector ^
            i.sendCall.selector ^
            i.sendCallNoReturn.selector ^
            i.withdraw.selector ^
            i.destroy.selector;
    }
}
