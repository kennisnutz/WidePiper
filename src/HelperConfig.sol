// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script}  from "forge-std/Script.sol";


contract HelperConfig  {

    NetworkConfig public activeNetWorkConfig;


    constructor() {
        activeNetWorkConfig = getMainnetForkConfig();
    }

    struct NetworkConfig {
        address  wethAddress;
        address  toncoinAddress;
        address  pancakePoolFactory;
        address  pancakeRouter;
    }
    

    function getMainnetForkConfig() public pure returns (NetworkConfig memory){
        NetworkConfig memory mainnetForkConfig = NetworkConfig({
            wethAddress : 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            toncoinAddress : 0x582d872A1B094FC48F5DE31D3B73F2D9bE47def1,
            pancakePoolFactory: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f,
            pancakeRouter : 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        });

        return mainnetForkConfig;
    }



}