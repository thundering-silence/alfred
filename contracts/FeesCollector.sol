// SPDX-License-Identifier: GPL3-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


/**
 * @notice Catalyst's Fees Collector
 */
contract FeesCollector is Ownable {
    using SafeERC20 for IERC20;

    event Transfer(address indexed asset, uint256 amount, address to);

    receive() external payable {}

    fallback() external {}

    struct TransferParams {
        IERC20 asset;
        address to;
    }

    /**
     * @notice Transfer tokens to other addresses
     * @dev Pass IERC20(address(0)) to send the native coin.
     * @param transfers - list of TransferParams
     */
    function transferOut(TransferParams[] calldata transfers) public onlyOwner {
        uint256 l = transfers.length-1;
        uint256 amount;
        for (uint i; i <= l; ++i) {
            IERC20 asset = transfers[i].asset;
            address to = transfers[i].to;
            if (address(asset) == address(0)) {
                amount = address(this).balance;
                payable(to).transfer(amount);
            } else {
                amount = asset.balanceOf(address(this));
                asset.safeTransfer(to, amount);
            }
            emit Transfer(address(asset), amount, to);
        }
    }

}
