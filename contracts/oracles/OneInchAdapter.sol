// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "../interfaces/swaps/ISwapDataRequester.sol";
import "../interfaces/swaps/ISwapExecutor.sol";

contract OneInchAdapter is ISwapDataRequester {
    using Strings for address;
    using Strings for uint256;

    event APIRequest(
        string endpoint,
        string path,
        address callbackAddress,
        bytes4 callbackFuncSelector
    );

    address internal _aggregatorV4;

    constructor(address aggregator_) {
        _aggregatorV4 = aggregator_;
    }

    function aggregator() public view returns (address) {
        return _aggregatorV4;
    }

    function _buildEndpoint(
        ISwapDataRequester.SwapDataParams calldata swapParams
    ) internal pure returns (string memory reqURI) {
        reqURI = string.concat(
            "https://api.1inch.io/v4.0/137/swap?fromTokenAddress=",
            swapParams.fromTokenAddress.toHexString(),
            "&toTokenAddress=",
            swapParams.toTokenAddress.toHexString(),
            "&amount=",
            swapParams.amount.toString(),
            "&slippage=",
            swapParams.slippage.toString(),
            "&fromAddress=",
            swapParams.fromAddress.toHexString(),
            "&destReceiver=",
            swapParams.destReceiver.toHexString()
        );
    }

    function request(
        ISwapDataRequester.CallbackParams calldata callbackParams,
        ISwapDataRequester.SwapDataParams calldata swapParams
    ) public {
        emit APIRequest(
            _buildEndpoint(swapParams),
            "tx,data",
            callbackParams.callee,
            callbackParams.functionSelector
        );
    }
}
