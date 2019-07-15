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
    Mock mock;

    function setUp() public {
        account = new MixAccount();
        mock = new Mock();
    }

    function testControlSendMixNoValue() public {
        account.sendMix.value(50)(address(0x1234));
    }

    function testFailSendMixNoValue() public {
        account.sendMix.value(0)(address(0x1234));
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

}

contract Mock {

    function() external payable {
        revert("error");
    }

    function returnNoError() public payable {
    }

    function returnError() public payable {
        revert("error");
    }

}
