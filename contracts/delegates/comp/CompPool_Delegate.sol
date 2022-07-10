// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/third-party/Compound/ICompToken.sol";
import "../../interfaces/third-party/Compound/IComptroller.sol";
import "../../interfaces/delegates/IPoolDelegate.sol";

import "hardhat/console.sol";

contract CompPoolDelegate is IPoolDelegate {
    function supply(IPoolDelegate.CallParams calldata params) external payable {
        require(msg.value == 0, "Delegate: 400");
        ICompToken cToken = ICompToken(params.pool);
        _enterMarket(params);
        IERC20(cToken.underlying()).approve(params.pool, params.amount);
        cToken.mint(params.amount);
    }

    function withdraw(IPoolDelegate.CallParams calldata params) external {
        ICompToken cToken = ICompToken(params.pool);
        cToken.redeemUnderlying(params.amount);
    }

    function borrow(IPoolDelegate.CallParams calldata params) external {
        _enterMarket(params);
        ICompToken(params.pool).borrow(params.amount);
        IERC20(params.asset).transfer(msg.sender, params.amount);
    }

    function repay(IPoolDelegate.CallParams calldata params) external payable {
        require(msg.value == 0, "Delegate: 400");
        ICompToken cToken = ICompToken(params.pool);
        IERC20(cToken.underlying()).approve(params.pool, params.amount);
        cToken.repayBorrow(params.amount);
    }

    function supplied(address asset) external view returns (uint256) {
        ICompToken cToken = ICompToken(asset);
        uint256 balance = (cToken.balanceOf(msg.sender) *
            cToken.exchangeRateStored()) / 1e18;
        console.log("supplied = %s", balance);
        return balance;
    }

    function borrowed(address asset) external view returns (uint256) {
        ICompToken cToken = ICompToken(asset);
        return cToken.borrowBalanceStored(msg.sender);
    }

    function _enterMarket(CallParams calldata params) public {
        IComptroller comptroller = IComptroller(params.controller);
        address[] memory cTokens = new address[](1);
        cTokens[0] = params.pool;
        comptroller.enterMarkets(cTokens);
    }
}
