// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/third-party/0vix/IoMATIC.sol";
import "../../interfaces/third-party/Compound/IComptroller.sol";
import "../../interfaces/delegates/IPoolDelegate.sol";

import "hardhat/console.sol";

contract ZeroVixPoolDelegate is IPoolDelegate {
    function supply(IPoolDelegate.CallParams calldata params) external payable {
        IoMATIC cToken = IoMATIC(params.pool);
        _enterMarket(params);
        cToken.mint{value: msg.value}();
    }

    function withdraw(IPoolDelegate.CallParams calldata params) external {
        ICompToken cToken = ICompToken(params.pool);
        cToken.redeemUnderlying(params.amount);
    }

    function borrow(IPoolDelegate.CallParams calldata params) external {
        console.log("1");
        _enterMarket(params);
        console.log("2");

        console.log(params.pool);
        uint errCode = IoMATIC(params.pool).borrow(params.amount);
        console.log(errCode);
        console.log("3");
        payable(msg.sender).transfer(params.amount);
    }

    function repay(IPoolDelegate.CallParams calldata params) external payable {
        IoMATIC cToken = IoMATIC(params.pool);
        cToken.repayBorrow{value: msg.value}();
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
