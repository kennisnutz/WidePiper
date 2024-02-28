// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts/utils/math/Math.sol';


import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IPancakeRouter01.sol";
import "./interfaces/IPancakeV2Pair.sol";
import './utils/Counters.sol';


interface IWidePiperTokenInterface is IERC20 {
    function burn(uint256 _amount) external ;
     function mint(address to, uint256 amount) external;
}

contract AssetManager is Ownable {
    using Counters for Counters.Counter;
    using Math for uint256;
    using Math for uint;
    using Math for uint112;
    using Math for uint8;

    Counters.Counter private _nodeCount;
    Counters.Counter private _currentBlockNo;

    IWidePiperTokenInterface private widePiperTokenContract;
    IERC20 private toncoinContract;

    IPancakeFactory private pancakeFactoryContract;
    IPancakeRouter01 private pancakeRouterContract;

    IPancakeV2Pair private tonWidePiperPoolContract;
    IPancakeV2Pair private ethWidePiperPoolContract;
    IPancakeV2Pair private tonEthPairContract;
    

    address public toncoinAddress;
    address public widePiperTokenAddress;
    address public wethAddress;

    address private tonWidepiperPoolAddress;
    address private ethWidepiperPoolAddress;
    address private tonEthLpAddress; 
    

    uint public lastTonEthPrice;
    //  The time of the next block processing operation
    uint256 public nextBlockTime;
    // the interval between block processing operations
    uint256 public blockInterval= 10 minutes;

    




     struct Node {
        uint256 id;
        NodeType nodeType;
        address owner;
        uint256 risk;
        uint256 reward;
       
    }

     enum NodeType {
        ETH, TON
    }

    Node[] private tonNodes;
    Node[] private ethNodes;



   


    //Modifier

    modifier onlyDuringWagerOpen() {
        (, uint256 wagerOpenTime) = blockInterval.tryDiv(2); // 5 minutes
        (,uint256 deadline) = nextBlockTime.trySub(block.timestamp);
        require(deadline > wagerOpenTime , "Asset Manager: Wagering closed");
        _;
    }

    constructor (
        address _toncoinAddress, 
        address _widePiperTokonAddress,
        address _wethAddress, 
        address _pancakePoolFactory, 
        address _pancakeRouter
    )Ownable(msg.sender){
        nextBlockTime = block.timestamp + blockInterval;
        widePiperTokenContract = IWidePiperTokenInterface(_widePiperTokonAddress);
        wethAddress = wethAddress;
        toncoinContract = IERC20(_toncoinAddress);
        pancakeRouterContract= IPancakeRouter01(_pancakeRouter);
        pancakeFactoryContract = IPancakeFactory(_pancakePoolFactory);
        tonEthLpAddress =  pancakeFactoryContract.getPair(_toncoinAddress, _wethAddress);
        toncoinAddress = _toncoinAddress;
        widePiperTokenAddress = _widePiperTokonAddress;
        tonWidepiperPoolAddress = getPool(_toncoinAddress,_widePiperTokonAddress);
        ethWidepiperPoolAddress = getPool(_widePiperTokonAddress, _wethAddress);
        tonWidePiperPoolContract = IPancakeV2Pair(tonWidepiperPoolAddress);
        ethWidePiperPoolContract = IPancakeV2Pair(ethWidepiperPoolAddress);
        tonEthPairContract = IPancakeV2Pair(tonEthLpAddress);
        lastTonEthPrice = getTonEthPrice();

    }


    receive() external payable {
         require(msg.value>0, "Asset Manager: Insufficient Eth amount");
        
    }
   


 
    // @dev function for creating new ton nodes
    // @param uint256 _risk: amount of toncoin to be wagered;
    // @param uint8 _numRounds: number of rounds the wager should be considered;
    // @param address _owner: address to recive rewards and withdraw deposits to;
    // @note  wagering period has to be restricted to only the first five minutes of the current block
    // so that users cannot simply create nodes seconds before the processing operation is commenced

    function createTonNode(uint256 _risk,  address _owner) external onlyDuringWagerOpen {                
        // mint new widepiper tokens and pair with half the deposited tokens
            require(toncoinContract.balanceOf(msg.sender) >= _risk, "Asset Manager: Insufficient  ton balance to cover risk");
              Node memory newNode = Node(
                _nodeCount.current(),
                NodeType.TON,
                _owner,
                _risk,
                0
            );

            toncoinContract.transferFrom(msg.sender, address(this),  newNode.risk);          
            
            // calculate amount of new widepiper tokens to mint;
            // how many widepiper tokens should be paired with _risk.tryDiv(2)?
            
            (, uint256 tonAmount)= newNode.risk.tryDiv(2);
            (,uint256 tonSlippage)=tonAmount.tryDiv(100);// 1% slippage
            (,uint256 minTonAmount)= tonAmount.trySub(tonSlippage);
            (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast)=   tonWidePiperPoolContract.getReserves();
            // if reserve0==0 | reserve1== 0: use the initial price to calculate number of tokens to mint
            //else:
            uint widepiperTokensToMintAmt=  pancakeRouterContract.quote(tonAmount, uint(reserve1), uint(reserve0));
            (, uint256 widepiperSlippage)=widepiperTokensToMintAmt.tryDiv(100);
            (,uint minWidepiperTokensToMintAmt)= widepiperTokensToMintAmt.trySub(widepiperSlippage);
            (,uint deadline)= uint(blockTimestampLast).tryAdd(1 minutes);
            //mint required amount of widepiper tokens
            widePiperTokenContract.mint(address(this), widepiperTokensToMintAmt);
            
            // add minted tokens with _risk.tryDiv(2) to ton-widePiper lp address
            widePiperTokenContract.approve(address(pancakeRouterContract), widepiperTokensToMintAmt);
            toncoinContract.approve(address(pancakeRouterContract), tonAmount);
            
            pancakeRouterContract.addLiquidity(
                    toncoinAddress,
                    widePiperTokenAddress,
                    uint(tonAmount),
                    widepiperTokensToMintAmt,
                    uint(minTonAmount),
                    minWidepiperTokensToMintAmt,
                    address(this),
                    deadline
            );
        // create and store new node a new TonNode with the given parameters
        
       
        tonNodes.push(newNode);
        _nodeCount.increment();    
        
    }


    function createEthNode(uint256 _risk,  address _owner) payable external {
        require(msg.value >= _risk, "Asset Manager: Insufficient eth balance to cover risk");
        _createEthNode(_risk, _owner);
    }

    
   

    /// @dev function for processing nodes; 
    /// Will be called at 10 minute intervals and implements the distribuition logic
    /// 1. get tonEth price

    function processBlock() public {
        _currentBlockNo.increment();
        
        nextBlockTime = block.timestamp + blockInterval;
    }




    // private  functions   
    function _createEthNode(uint256 _risk,  address _owner) private {     

        // calculate amount of new widepiper tokens to mint;
        // how many widepiper tokens should be paired with _risk.tryDiv(2)?
        (, uint256 wethAmount)= msg.value.tryDiv(2);
        (,uint256 wethSlippage)=wethAmount.tryDiv(100);// 1% slippage
        (,uint256 minWethAmount)= wethAmount.trySub(wethSlippage);
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) =   ethWidePiperPoolContract.getReserves();
        
        uint widepiperTokensToMintAmt=  pancakeRouterContract.quote(wethAmount, uint(reserve1), uint(reserve0));
        (, uint256 widepiperSlippage)=widepiperTokensToMintAmt.tryDiv(100);
        (,uint minWidepiperTokensToMintAmt)= widepiperTokensToMintAmt.trySub(widepiperSlippage);
        (,uint deadline)= uint(blockTimestampLast).tryAdd(1 minutes);

        //mint required amount of widepiper tokens
        widePiperTokenContract.mint(address(this), widepiperTokensToMintAmt);
        
        // add minted tokens with _risk.tryDiv(2) to ton-widePiper lp address
        widePiperTokenContract.approve(address(pancakeRouterContract), widepiperTokensToMintAmt);            

        (bool success,)= payable(address(pancakeRouterContract)).call{value: msg.value}(
            abi.encodeWithSignature(
                "addLiquidityETH(address,uint256,uint256,uint256,address,uint256)",
                widePiperTokenAddress,                    
                widepiperTokensToMintAmt,                    
                minWidepiperTokensToMintAmt,
                uint(minWethAmount),
                address(this),
                deadline
            )
        );            
        require(success, "Asset Manager: Failed to add Liquidity");           
            
        

        // create and store new node a new TonNode with the given parameters
         Node memory newNode = Node(
            _nodeCount.current(),
            NodeType.ETH,
            _owner,
            _risk,
            0
        );
        ethNodes.push(newNode);
        _nodeCount.increment(); 
    }







    // view/read functions

     function getPool(address _tokenA, address _tokenB) public view returns(address){
        address poolAddress = pancakeFactoryContract.getPair(toncoinAddress, wethAddress);               
        return poolAddress;
    }

    function getTonEthPrice() public view returns (uint){       
         (uint112 tonReserve, uint112 ethReserve, uint32 blockTimestampLast)=   tonEthPairContract.getReserves();
          uint ethPriceOf1Ton =  pancakeRouterContract.quote(1 * 10 ** 9, uint(tonReserve), uint(ethReserve));
         return ethPriceOf1Ton;
    }

    function getCurrentBlockNumber() public view returns(uint256){
        return _currentBlockNo.current();
    }

    function getTonWidepiperPool() public view returns(address){
        return tonWidepiperPoolAddress;
    }

    function getEthWidepiperPool() public view returns(address){
        return ethWidepiperPoolAddress;
    }
    

    function getTonNodeCount() public view returns(uint){
        return tonNodes.length;
    }

    function getEthNodeCount() public view returns(uint){
        return ethNodes.length;
    }

    function getWidePiperEthLpBalance() public view returns(uint contractBalance){
        contractBalance = ethWidePiperPoolContract.balanceOf(address(this));
    }

    function getWidePiperTonLpBalance() public view returns(uint contractBalance){
        contractBalance = tonWidePiperPoolContract.balanceOf(address(this));
    }

}