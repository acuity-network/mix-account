pragma solidity ^0.5.4;

import "ds-test/test.sol";

import "./Account.sol";


/**
 * @title AccountTest
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Testing contract for Account.
 */
contract AccountTest is DSTest {

    Account account;

    function setUp() public {
        account = new Account();
    }

    function testControlSendMixNoValue() public {
        account.sendMix.value(50)(address(0x1234));
    }

    function testFailSendMixNoValue() public {
        account.sendMix.value(0)(address(0x1234));
    }

    function testSendMix() public {
        assertEq(address(0x1234).balance, 0);
        account.sendMix.value(50)(address(0x1234));
        assertEq(address(0x1234).balance, 50);
    }

}
