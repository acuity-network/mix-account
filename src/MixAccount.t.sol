pragma solidity ^0.5.10;

import "ds-test/test.sol";

import "./MixAccount.sol";


/**
 * @title MixAccountTest
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Testing contract for MixAccount.
 */
contract MixAccountTest is DSTest {

    MixAccount account;
    MixAccountProxy accountProxy;
    Mock mock;

    function() external payable {}

    function setUp() public {
        account = new MixAccount();
        accountProxy = new MixAccountProxy(account);
        mock = new Mock();
    }

    function testFailSetControllerNotController() public {
        accountProxy.setController(address(0x1234));
    }

    function testSetController() public {
        account.setController(address(accountProxy));
        accountProxy.setController(address(0x1234));
    }

    function testSendMixSuccess() public {
        assertEq(address(0x1234).balance, 0);
        bool result = account.sendMix.value(50)(address(0x1234));
        assertTrue(result);
        assertEq(address(0x1234).balance, 50);
    }

    function testSendMixFail() public {
        assertEq(address(mock).balance, 0);
        bool result = account.sendMix.value(50)(address(mock));
        assertTrue(!result);
        assertEq(address(mock).balance, 0);
    }

    function testSendDataSuccess() public {
        assertEq(address(mock).balance, 0);
        bool result = account.sendData.value(50)(address(mock), hex"cf7d0b9f");
        assertTrue(result);
        assertEq(address(mock).balance, 50);
    }

    function testSendDataFail() public {
        assertEq(address(mock).balance, 0);
        bool result = account.sendData.value(50)(address(mock), hex"dad03cb0");
        assertTrue(!result);
        assertEq(address(mock).balance, 0);
    }

    function testControlWithdrawNotController() public {
        account.withdraw();
    }

    function testFailWithdrawNotController() public {
        accountProxy.withdraw();
    }

    function testWithdraw() public {
        uint startMix = address(this).balance;
        assertEq(address(account).balance, 0);
        address(account).transfer(50);
        assertEq(address(account).balance, 50);
        assertEq(address(this).balance, startMix - 50);
        account.withdraw();
        assertEq(address(account).balance, 0);
        assertEq(address(this).balance, startMix);
    }

    function testControlDestroyNotController() public {
        account.destroy();
    }

    function testFailDestroyNotController() public {
        accountProxy.destroy();
    }

    function testDestroy() public {
        uint startMix = address(this).balance;
        assertEq(address(account).balance, 0);
        address(account).transfer(50);
        assertEq(address(account).balance, 50);
        assertEq(address(this).balance, startMix - 50);
        account.destroy();
        assertEq(address(account).balance, 0);
        assertEq(address(this).balance, startMix);
    }

    function testCallback() public {
        address(account).transfer(50);
    }

    function testOnMixTokenReceived() public {
        assertEq(bytes32(accountProxy.onMixTokenReceived(address(0), 0, hex"")), bytes32(hex"3c8c71b0"));
    }

    function testOnERC1155Received() public {
        assertEq(bytes32(accountProxy.onERC1155Received(address(0), address(0), 0, 0, hex"")), bytes32(hex"f23a6e61"));
    }

    function testOnERC1155BatchReceived() public {
        uint[] memory empty = new uint[](0);
        assertEq(bytes32(accountProxy.onERC1155BatchReceived(address(0), address(0), empty, empty, hex"")), bytes32(hex"bc197c81"));
    }

    function testSupportsInterface() public {
        assertTrue(!account.supportsInterface(0x00000000));
        assertTrue(!account.supportsInterface(0xffffffff));
        assertTrue(account.supportsInterface(0x01ffc9a7));
        assertTrue(account.supportsInterface(0x4e2312e0));
    }

}

contract MixAccountProxy is MixAccountInterface, MixTokenReceiverInterface, ERC1155TokenReceiver {

    MixAccount mixAccount;

    /**
     * @param _mixAccount Real MixAccount contract to proxy to.
     */
    constructor (MixAccount _mixAccount) public {
        mixAccount = _mixAccount;
    }

    function setController(address payable newController) external {
        mixAccount.setController(newController);
    }

    function sendMix(address to) external payable returns (bool success) {
        success = mixAccount.sendMix(to);
    }

    function sendData(address to, bytes calldata data) external payable returns (bool success) {
        success = mixAccount.sendData(to, data);
    }

    function withdraw() external {
        mixAccount.withdraw();
    }

    function destroy() external {
        mixAccount.destroy();
    }

    function() external payable {}

    function onMixTokenReceived(address from, uint value, bytes calldata data) external returns (bytes4) {
        return mixAccount.onMixTokenReceived(from, value, data);
    }

    function onERC1155Received(address operator, address from, uint id, uint value, bytes calldata data) external returns (bytes4) {
        return mixAccount.onERC1155Received(operator, from, id, value, data);
    }

    function onERC1155BatchReceived(address operator, address from, uint[] calldata ids, uint[] calldata values, bytes calldata data) external returns (bytes4) {
        return mixAccount.onERC1155BatchReceived(operator, from, ids, values, data);
    }
}

contract Mock {

    function() external payable {
        revert("fallback error");
    }

    function returnNoError() public payable {
    }

    function returnError() public payable {
        revert("error");
    }

}
