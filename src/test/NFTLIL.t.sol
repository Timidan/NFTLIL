// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import {IWitnetRandomness} from "../IWIT.sol";
import "../NFTLIL.sol";

contract ContractTest is DSTest {
    NFTLIL l;
    IWitnetRandomness r =
        IWitnetRandomness(address(0xa784093826e2894Ab3Db315f4e05F0F26407BBfF));

    function setUp() public {
        l = new NFTLIL(r);
    }

    // function testMetadata() public {
    //     l.mintNFT();
    //     l.mintNFT();
    //     l.getToken(0);
    //     l.tokenURI(1);
    // }
}
