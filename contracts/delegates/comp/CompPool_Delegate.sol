// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/third-party/Compound/ICompToken.sol";
import "../../interfaces/third-party/Compound/IComptroller.sol";
import "../../interfaces/delegates/IPoolDelegate.sol";

contract CompPoolDelegate is IPoolDelegate {
    function supply(IPoolDelegate.CallParams calldata params) external {
        ICompToken cToken = ICompToken(params.pool);
        _toggleMarket(params, true);
        IERC20(cToken.underlying()).approve(params.pool, params.amount);
        cToken.mint(params.amount);
    }

    function withdraw(IPoolDelegate.CallParams calldata params) external {
        ICompToken cToken = ICompToken(params.pool);
        cToken.redeemUnderlying(params.amount);
    }

    function borrow(IPoolDelegate.CallParams calldata params) external {
        _toggleMarket(params, true);
        ICompToken(params.pool).borrow(params.amount);
    }

    function repay(IPoolDelegate.CallParams calldata params) external {
        ICompToken cToken = ICompToken(params.pool);
        IERC20(cToken.underlying()).approve(params.pool, params.amount);
        cToken.repayBorrow(params.amount);
    }

    function supplied(IPoolDelegate.CallParams calldata params)
        external
        returns (uint256)
    {
        ICompToken cToken = ICompToken(params.pool);
        return cToken.balanceOfUnderlying(address(this));
    }

    function borrowed(IPoolDelegate.CallParams calldata params)
        external
        returns (uint256)
    {
        ICompToken cToken = ICompToken(params.pool);
        return cToken.borrowBalanceCurrent(address(this));
    }

    function _toggleMarket(CallParams calldata params, bool enter) public {
        // IComptroller comptroller = IComptroller();
        // if (enter) {
        //     address[] memory cTokens = new address[](1);
        //     cTokens[0] = params.pool;
        //     comptroller.enterMarkets(cTokens);
        // } else {
        //     comptroller.exitMarket(params.pool);
        // }
    }
}
