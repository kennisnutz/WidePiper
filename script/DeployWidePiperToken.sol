// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {WidePiperToken} from "../src/WidePiperToken.sol";

contract DeployWidePiperToken is Script {
    function setUp() public {}
    
    function run() external returns(WidePiperToken) {
        vm.startBroadcast();
        WidePiperToken widePiperToken = new WidePiperToken();
        vm.stopBroadcast();
        return widePiperToken;
    }
}
