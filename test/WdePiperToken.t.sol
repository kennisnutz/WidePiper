// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WidePiperToken} from "../src/WidePiperToken.sol";

contract WidePiperTokenTest is Test {
    WidePiperToken public widePiperToken;
    uint256 internal adminPK;
    uint256 internal recipient1PK;
    address internal admin;
    address internal recipient1;

    uint256 initialMint= 200000000000 * 10 ** 18;

    function setUp() public {
        adminPK = 0xA11CE;
        recipient1PK = 0xB0B;
        admin = vm.addr(adminPK);
        recipient1 = vm.addr(recipient1PK);
        widePiperToken = new WidePiperToken();
        widePiperToken.setAdmin(admin);
    }

    function test_InitialMint() public {
        uint256 tokenBalance = widePiperToken.balanceOf(address(this));
        assertEq(tokenBalance, initialMint);
    }

    function test_SetAdmin() public{
        address ad = widePiperToken.getAdmin();
        assertEq(admin,ad);
    }

    function test_Transfer() public{
        uint256 transferAmount = 100000 * 10 ** 18;
        widePiperToken.transfer(recipient1, transferAmount);
        assertEq(widePiperToken.balanceOf(recipient1), transferAmount);
    }  

    function test_Minting() public {
        uint256 mintAmount = 100000 * 10 ** widePiperToken.decimals();
        uint256 initBalance = widePiperToken.balanceOf(address(recipient1));
        vm.startBroadcast(admin);
        widePiperToken.mint(address(recipient1),mintAmount);
        vm.stopBroadcast();
        assertEq(widePiperToken.balanceOf(address(recipient1)), initBalance + mintAmount);

    }
    function test_Only_Admin_Minting() public {
        uint256 mintAmount = 100000 * 10 ** widePiperToken.decimals();
        vm.expectRevert("WidePiper Token:Unauthorized sender");
        widePiperToken.mint(address(recipient1),mintAmount);
    }

    function test_Burning() public {
         uint256 burnAmount = 100000 * 10 ** widePiperToken.decimals();
         uint256 initSupply = widePiperToken.totalSupply();
        widePiperToken.burn(burnAmount);
        assertEq(widePiperToken.totalSupply(), initSupply - burnAmount);
    }

}
