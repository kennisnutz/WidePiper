// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract WidePiperToken is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    error WidePiperToken_MustBeMoreThanZero();
    error WidePiperToken_BurnAmountExceedsBalance();
    address private admin;

    constructor()
        ERC20("WidePiper  Token", "WPT")
        Ownable(msg.sender)
        ERC20Permit("Wide Piper Token")
    {
        
        _mint(msg.sender, 200000000000 * 10 ** decimals());
    }

    function burn(uint256 _amount) public override  {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert WidePiperToken_MustBeMoreThanZero();
        }
        if (balance < _amount) {
            revert WidePiperToken_BurnAmountExceedsBalance();
        }
        super.burn(_amount);
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender==admin, "WidePiper Token:Unauthorized sender");
        _mint(to, amount);
    }

    function setAdmin(address _admin) public onlyOwner{
        admin = _admin;
    }
    function getAdmin() public view returns(address){
        return admin;
    }



}