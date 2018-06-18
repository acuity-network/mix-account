pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./account.sol";


/**
 * @title AccountTest
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Testing contract for Account.
 */
contract AccountTest is DSTest {

    Account account;

    function setUp() public {
        account = new Account(this);
    }


    function testControlSendMixNoValue() public {
        account.sendMix.value(50)(0x1234);
    }

    function testFailSendMixNoValue() public {
        account.sendMix.value(0)(0x1234);
    }

    function testSendMix() public {
        assertEq(address(0x1234).balance, 0);
        account.sendMix.value(50)(0x1234);
        assertEq(address(0x1234).balance, 50);
    }


    function testCallH() public {
        assertEq(address(0x1234).balance, 0);
        account.callH.value(50)(0x1234, '', 32);
        assertEq(address(0x1234).balance, 50);
    }


    function testCallB() public {
        assertEq(address(0x1234).balance, 0);
        account.callB.value(50)(0x1234, '');
        assertEq(address(0x1234).balance, 50);
    }


    function testStaticCall() public {
        account.staticCall(0x1234, '');
    }

}
