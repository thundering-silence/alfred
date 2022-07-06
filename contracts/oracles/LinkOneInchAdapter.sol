// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "hardhat/console.sol";

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../interfaces/swaps/ISwapDataRequester.sol";
import "../interfaces/swaps/ISwapExecutor.sol";

contract LinkOneInchAdapter is ISwapDataRequester, Ownable, ChainlinkClient {
    using Chainlink for Chainlink.Request;
    using SafeERC20 for IERC20;
    using Strings for address;
    using Strings for uint256;

    event APIRequest(
        string endpoint,
        string path,
        address callbackAddress,
        bytes4 callbackFuncSelector
    );

    address internal _aggregatorV4;
    bytes32 internal _jobId;
    uint256 internal _fee;

    constructor(
        address aggregator_,
        bytes32 jobId_,
        uint256 fee_,
        address linkToken,
        address oracle
    ) {
        setChainlinkToken(linkToken);
        setChainlinkOracle(oracle);
        _aggregatorV4 = aggregator_;
        _jobId = jobId_;
        _fee = fee_;
    }

    function aggregator() public view returns (address) {
        return _aggregatorV4;
    }

    function jobId() public view returns (bytes32) {
        return _jobId;
    }

    function fee() public view returns (uint256) {
        return _fee;
    }

    function _buildEndpoint(
        ISwapDataRequester.SwapDataParams calldata swapParams
    ) internal pure returns (string memory reqURI) {
        reqURI = string.concat(
            "https://api.1inch.io/v4.0/43114/swap?fromTokenAddress=",
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
        Chainlink.Request memory req = buildChainlinkRequest(
            _jobId,
            callbackParams.callee,
            callbackParams.functionSelector
        );

        req.add("get", _buildEndpoint(swapParams));
        req.add("path", "tx,data");

        sendChainlinkRequest(req, _fee);
    }

    function withdrawLink(uint256 amount) public onlyOwner {
        IERC20(chainlinkTokenAddress()).safeTransfer(owner(), amount);
    }
}
