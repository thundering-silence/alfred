// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./interfaces/delegates/IPoolDelegate.sol";
import "./interfaces/third-party/Compound/ICompToken.sol";
import "./interfaces/third-party/Compound/IComptroller.sol";
import "./interfaces/swaps/ISwapDataRequester.sol";
import "./interfaces/swaps/ISwapExecutor.sol";

import "./BaseVault.sol";

contract Vault is ISwapExecutor, BaseVault {
    using SafeERC20 for IERC20;
    using Address for address;

    ISwapDataRequester internal _swapper;
    address internal _feesCollector;

    constructor(
        string memory name_,
        address swapper_,
        address feesCollector_,
        address configProvider_
    ) BaseVault(configProvider_, name_) {
        _swapper = ISwapDataRequester(swapper_);
        _feesCollector = feesCollector_;
    }

    function requestSwaps(address[] calldata assets) public {
        uint256 loops = assets.length;
        for (uint256 i; i < loops; ++i) {
            uint256 balance = IERC20(assets[i]).balanceOf(address(this));
            ISwapDataRequester.CallbackParams
                memory callbackParams = ISwapDataRequester.CallbackParams({
                    callee: address(this),
                    functionSelector: this.executeSwap.selector
                });
            ISwapDataRequester.SwapDataParams
                memory swapParams = ISwapDataRequester.SwapDataParams({
                    fromTokenAddress: assets[i],
                    toTokenAddress: _currentDebtAsset,
                    amount: balance,
                    slippage: 5,
                    fromAddress: address(this),
                    destReceiver: address(this),
                    allowPartialFill: true
                });
            IERC20(assets[i]).safeIncreaseAllowance(
                _swapper.aggregator(),
                balance
            );
            _swapper.request(callbackParams, swapParams);
        }
    }

    /**
     * @notice Check that the swap receiver and the destination token are correct
     */
    function checkData(bytes calldata data) public view {
        (, ISwapExecutor.SwapDescription memory desc, ) = abi.decode(
            data[4:],
            (address, SwapDescription, bytes)
        );

        require(
            address(desc.dstReceiver) == address(this),
            "Vault: wrong swap dstReceiver"
        );
        require(
            desc.dstToken == _currentDebtAsset,
            "Vault: wrong swap dstToken"
        );
    }

    function executeSwap(bytes calldata data) public {
        checkData(data);
        uint256 balanceBefore = IERC20(_currentDebtAsset).balanceOf(
            address(this)
        );
        _swapper.aggregator().functionCall(data);
        uint256 balanceAfter = IERC20(_currentDebtAsset).balanceOf(
            address(this)
        );

        uint256 amount = balanceAfter - balanceBefore;
        require(amount > 0);
        uint256 amountToRepay = _handleFees(amount);
        IPoolDelegate.CallParams memory callParams = IPoolDelegate.CallParams({
            pool: _currentDebtPool,
            asset: _currentDebtAsset,
            amount: amountToRepay,
            controller: address(0)
        });
        _repay(callParams);
    }

    function _handleFees(uint256 amount) internal virtual returns (uint256) {
        uint256 devCut = amount > 100 ? amount / 100 : 0; // 1% to dev
        uint256 executorCut = amount > 25 ? amount / 25 : 0; // 4% to executor

        IERC20(_currentDebtAsset).transfer(_feesCollector, devCut);
        IERC20(_currentDebtAsset).transfer(_msgSender(), executorCut);
        return amount - devCut - executorCut;
    }
}
