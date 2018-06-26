pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./account.sol";

import "../mix-item-store/src/item_store_registry.sol";
import "../mix-item-store/src/item_store_ipfs_sha256.sol";


/**
 * @title AccountTest
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Testing contract for Account.
 */
contract AccountTest is DSTest {

    ItemStoreRegistry itemStoreRegistry;
    ItemStoreIpfsSha256 itemStore;
    Account account;

    function setUp() public {
        itemStoreRegistry = new ItemStoreRegistry();
        itemStore = new ItemStoreIpfsSha256(itemStoreRegistry);
        account = new Account();
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

    function testCallHWithData() public {
        bytes32 itemId = account.callH(itemStore, hex"49ee6c5000f7a50039f2095cc5f0f96897eebce6184074b4c18ab6db414ec3f82e628bf8", 32);
        assertEq(itemId, 0xb3cfcea9d2eb30b7242c04dab67f4d574ac28d694e8c2d51432bba5cd5b29570);
    }

    function testCallB() public {
        assertEq(address(0x1234).balance, 0);
        account.callB.value(50)(0x1234, '');
        assertEq(address(0x1234).balance, 50);
    }

    function testStaticCall() public view {
        account.staticCall(0x1234, '');
    }

}
