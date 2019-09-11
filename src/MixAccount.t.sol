pragma solidity ^0.5.11;

import "ds-test/test.sol";

import "./MixAccount.sol";


contract MixAccountTest is DSTest {

    MixAccount mixAccount;
    MixAccountProxy mixAccountProxy;
    Mock mock;

    function() external payable {}

    function setUp() public {
        mixAccount = new MixAccount();
        mixAccountProxy = new MixAccountProxy(mixAccount);
        mock = new Mock();
    }

    function testFailSetControllerNotController() public {
        mixAccountProxy.setController(address(0x1234));
    }

    function testSetController() public {
        mixAccount.setController(address(mixAccountProxy));
        mixAccountProxy.setController(address(0x1234));
    }

    function testSendCallSuccess() public {
        uint startBalance = address(this).balance;
        assertEq(address(mock).balance, 0);
        (bool success, bytes memory returnData) = mixAccount.sendCall.value(50)(address(mock), hex"cf7d0b9f");
        assertTrue(success);
        assertEq0(returnData, hex"000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000077375636365737300000000000000000000000000000000000000000000000000");
        assertEq(address(mock).balance, 50);
        assertEq(address(this).balance, startBalance - 50);
    }

    function testSendCallFail() public {
        uint startBalance = address(this).balance;
        assertEq(address(mock).balance, 0);
        (bool success, bytes memory returnData) = mixAccount.sendCall.value(50)(address(mock), hex"dad03cb0");
        assertTrue(!success);
        assertEq0(returnData, hex"08c379a0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000056572726f72000000000000000000000000000000000000000000000000000000");
        assertEq(address(mock).balance, 0);
        assertEq(address(this).balance, startBalance);
    }

    function testSendCallNoReturnSuccess() public {
        uint startBalance = address(this).balance;
        assertEq(address(mock).balance, 0);
        mixAccount.sendCallNoReturn.value(50)(address(mock), hex"cf7d0b9f");
        assertEq(address(mock).balance, 50);
        assertEq(address(this).balance, startBalance - 50);
    }

    function testSendCallNoReturnFail() public {
        uint startBalance = address(this).balance;
        assertEq(address(mock).balance, 0);
        mixAccount.sendCallNoReturn.value(50)(address(mock), hex"dad03cb0");
        assertEq(address(mock).balance, 0);
        assertEq(address(this).balance, startBalance);
    }

    function testControlWithdrawNotController() public {
        mixAccount.withdraw();
    }

    function testFailWithdrawNotController() public {
        mixAccountProxy.withdraw();
    }

    function testWithdraw() public {
        uint startMix = address(this).balance;
        assertEq(address(mixAccount).balance, 0);
        address(mixAccount).transfer(50);
        assertEq(address(mixAccount).balance, 50);
        assertEq(address(this).balance, startMix - 50);
        mixAccount.withdraw();
        assertEq(address(mixAccount).balance, 0);
        assertEq(address(this).balance, startMix);
    }

    function testControlDestroyNotController() public {
        mixAccount.destroy();
    }

    function testFailDestroyNotController() public {
        mixAccountProxy.destroy();
    }

    function testDestroy() public {
        uint startMix = address(this).balance;
        assertEq(address(mixAccount).balance, 0);
        address(mixAccount).transfer(50);
        assertEq(address(mixAccount).balance, 50);
        assertEq(address(this).balance, startMix - 50);
        mixAccount.destroy();
        assertEq(address(mixAccount).balance, 0);
        assertEq(address(this).balance, startMix);
    }

    function testCallback() public {
        address(mixAccount).transfer(50);
    }

    function testOnERC1155Received() public {
        assertEq(bytes32(mixAccountProxy.onERC1155Received(address(0), address(0), 0, 0, hex"")), bytes32(hex"f23a6e61"));
    }

    function testOnERC1155BatchReceived() public {
        uint[] memory empty = new uint[](0);
        assertEq(bytes32(mixAccountProxy.onERC1155BatchReceived(address(0), address(0), empty, empty, hex"")), bytes32(hex"bc197c81"));
    }

    function testSupportsInterface() public {
        assertTrue(!mixAccount.supportsInterface(0x00000000));
        assertTrue(!mixAccount.supportsInterface(0xffffffff));
        assertTrue(mixAccount.supportsInterface(0x01ffc9a7));    // EIP165
        assertTrue(mixAccount.supportsInterface(0x4e2312e0));    // ERC1155TokenReceiver

        MixAccountInterfaceId mixAccountInterfaceId = new MixAccountInterfaceId();
        assertTrue(mixAccount.supportsInterface(mixAccountInterfaceId.getInterfaceId()));
    }

}

contract MixAccountProxy is MixAccountInterface, ERC1155TokenReceiver {

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

    function sendCall(address to, bytes calldata data) external payable returns (bool success, bytes memory returnData) {
        (success, returnData) = mixAccount.sendCall(to, data);
    }

    function sendCallNoReturn(address to, bytes calldata data) external payable {
        mixAccount.sendCallNoReturn(to, data);
    }

    function withdraw() external {
        mixAccount.withdraw();
    }

    function destroy() external {
        mixAccount.destroy();
    }

    function() external payable {}

    function onERC1155Received(address operator, address from, uint id, uint value, bytes calldata data) external returns (bytes4) {
        return mixAccount.onERC1155Received(operator, from, id, value, data);
    }

    function onERC1155BatchReceived(address operator, address from, uint[] calldata ids, uint[] calldata values, bytes calldata data) external returns (bytes4) {
        return mixAccount.onERC1155BatchReceived(operator, from, ids, values, data);
    }
}

contract Mock {

    function() external payable {
        revert ("fallback error");
    }

    function returnNoError() public payable returns (string memory message) {
        message = "success";
    }

    function returnError() public payable {
        revert ("error");
    }

}
