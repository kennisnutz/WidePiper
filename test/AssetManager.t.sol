// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WidePiperToken} from "../src/WidePiperToken.sol";
import {AssetManager} from "../src/AssetManager.sol";
import {IPancakeFactory} from "../src/interfaces/IPancakeFactory.sol";
import {IPancakeRouter01} from "../src/interfaces/IPancakeRouter01.sol";
import {IPancakeV2Pair} from "../src/interfaces/IPancakeV2Pair.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {HelperConfig} from "../src/HelperConfig.sol";



contract AssetManagerTest is Test {
    AssetManager public assetManager;
    WidePiperToken public widePiperToken;
    IPancakeFactory public pairFactory;
    IPancakeRouter01 public router;
    IPancakeV2Pair public pair;
    IERC20 public toncoinContract;
    IERC20 public wethContract;

    uint256 internal tonUserPk;
    uint256 internal ethUsePK;
    uint256 internal deployerPk;
    uint256 internal initWidePiperAmt;

    uint256 internal ethWidepiperPrice = 10000;
    uint256 internal initialEthLp = 100 ether;
    uint256 internal initialTonLp = 15000 * 10 ** 9;
    uint256 internal minTonDesired = initialTonLp-(initialTonLp / 100); //1% tolerance
    uint256 internal minEthDesired= initialEthLp -(initialEthLp / 100);
    uint256 internal deadline = block.timestamp + 1 minutes;
    
    address internal tonUser;
    address internal ethUser;
    address internal deployer;

    address tonWidepiperPair;
    address ethWidepiperPair;

    address internal wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal toncoinAddress = 0x582d872A1B094FC48F5DE31D3B73F2D9bE47def1;
    address internal pancakePoolFactory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address internal pancakeRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function setUp() public {
        tonUserPk = 0xA11CE;
        ethUsePK = 0xB0B;
        tonUser = vm.addr(tonUserPk);
        ethUser = vm.addr(ethUsePK);
        deployer = vm.addr(0xDE1);

        toncoinContract = IERC20(toncoinAddress);
        wethContract = IERC20(wethAddress);

        // deal toncoin to deployer address
        deal(address(toncoinAddress), deployer, 150000 * 10 ** 9);
        // deal eth to deployer address
        deal(deployer, 1000 ether);

         // deal Eth tokens to ethUser and deployer;
        deal(ethUser, 100 ether);
        //deal 1000 toncoin to tonUser
        deal(address(toncoinAddress), tonUser, 1000 * 10 ** 9);

        vm.startBroadcast(deployer);
        //deploy widepiper token
        widePiperToken = new WidePiperToken();
        vm.stopBroadcast();
        pairFactory = IPancakeFactory(pancakePoolFactory);
        router = IPancakeRouter01(pancakeRouter);
        

        // calculate widepiper amount for ethWidepiper price: 1 eth= 10000 widepiper tokens
        uint256 initialWidepiperForEthLp = ethWidepiperPrice * initialEthLp;

        //1% slippage
        uint256 minWidePiperDesiredForEthLp = initialWidepiperForEthLp - (initialWidepiperForEthLp / 100);
        
        // calculate widepiper amount for  tonWidepiper price: 1 eth= 150 ton= 10000 widepiper tokens
        uint256 initialWidepiperForTonLp = 10000 * initialTonLp / 150;

        //1% slippage
        uint256 minWidePiperDesiredForTonLp = initialWidepiperForTonLp - (initialWidepiperForTonLp / 100);

         vm.startBroadcast(deployer);
        //approve widepiper amount to tonWidepiper pair contract
        widePiperToken.approve(address(router), initialWidepiperForEthLp + initialWidepiperForTonLp );
        toncoinContract.approve(address(router), initialTonLp);
               
        // Create ethWidepiper pair
       router.addLiquidity(
        address(widePiperToken),
        toncoinAddress,
        initialWidepiperForTonLp,
        initialTonLp,
        minWidePiperDesiredForTonLp,
        minTonDesired,
        deployer,
        deadline
       );

        // Create tonWidepiper pair
        address(router).call{value: initialEthLp}(
            abi.encodeWithSignature(
                "addLiquidityETH(address,uint256,uint256,uint256,address,uint256)",
                address(widePiperToken),
                initialWidepiperForEthLp,
                minWidePiperDesiredForEthLp,
                minEthDesired,
                deployer,
                deadline + 1 minutes
            )
        );

        assetManager = new AssetManager(
            toncoinAddress,
            address(widePiperToken),
            wethAddress,
            pancakePoolFactory,
            pancakeRouter
        );      

        widePiperToken.setAdmin(address(assetManager));

        initWidePiperAmt = 400 * 10 ** widePiperToken.decimals();

        // approve initial widePiper token amount  to users;
        widePiperToken.approve(tonUser, initWidePiperAmt);
        widePiperToken.approve(ethUser, initWidePiperAmt);

         // send initial widePiper tokens to users;
        widePiperToken.transfer(tonUser, initWidePiperAmt);
        widePiperToken.transfer(ethUser, initWidePiperAmt);
        vm.stopBroadcast();       
     
    }

    function test_InitialWiderPiperTransfer() public {
        uint256 initalWiderPiperBalanceOfTonUser = widePiperToken.balanceOf(tonUser);
        uint256 initalWiderPiperBalanceOfEthUser = widePiperToken.balanceOf(ethUser);
        assertEq(initalWiderPiperBalanceOfTonUser,initWidePiperAmt);
        assertEq(initalWiderPiperBalanceOfEthUser,initWidePiperAmt);
    }

    function test_AssetManagerDeployment() public{
     
       
   }


   function test_TonNodeCreation() public {
   

   }

    function test_EthNodeCreation() public {
    

    } 
   


}