// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./interfaces/delegates/IPoolDelegate.sol";
import "./interfaces/third-party/Compound/ICompToken.sol";
import "./interfaces/third-party/Compound/IComptroller.sol";
import "./interfaces/IConfigProvider.sol";

import "hardhat/console.sol";

contract BaseVault is Ownable, IPoolDelegate {
    using SafeERC20 for IERC20;
    using Address for address;

    event Supply(address indexed pool, address indexed asset, uint256 amount);
    event Withdraw(address indexed pool, address indexed asset, uint256 amount);
    event Borrow(address indexed pool, address indexed asset, uint256 amount);
    event Repay(address indexed pool, address indexed asset, uint256 amount);

    string internal _name;
    mapping(address => mapping(address => uint256)) internal _supplied; // keep track of supplied amounts
    address internal _currentDebtPool;
    address internal _currentDebtAsset;
    IConfigProvider internal _configProvider;

    constructor(address configProvider_, string memory name_) {
        _configProvider = IConfigProvider(configProvider_);
        _name = name_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function setName(string calldata name_) public onlyOwner {
        _name = name_;
    }

    function currentDebtPool() public view returns (address) {
        return _currentDebtPool;
    }

    function currentDebtAsset() public view returns (address) {
        return _currentDebtAsset;
    }

    function supply(IPoolDelegate.CallParams calldata params) public onlyOwner {
        uint256 balance = IERC20(params.asset).balanceOf(address(this));
        // if not enough to supply, pull from sender
        if (balance < params.amount) {
            IERC20(params.asset).transferFrom(
                _msgSender(),
                address(this),
                params.amount - balance
            );
        }
        _supplied[params.pool][params.asset] += params.amount;
        bytes memory data = abi.encodeWithSignature(
            "supply((address,address,uint256))",
            params
        );
        address provider = _configProvider.getPoolDelegate(params.pool);
        provider.functionDelegateCall(data, "Vault: Failed to supply");
        emit Supply(params.pool, params.asset, params.amount);
    }

    function borrow(IPoolDelegate.CallParams calldata params) public onlyOwner {
        require(_currentDebtPool == address(0), "Vault: One loan at a time");
        require(_currentDebtAsset == address(0));
        _currentDebtAsset = params.asset;
        _currentDebtPool = params.pool;
        bytes memory data = abi.encodeWithSignature(
            "borrow((address,address,uint256))",
            params
        );
        _configProvider.getPoolDelegate(params.pool).functionDelegateCall(
            data,
            "Vault: Failed to borrow"
        );
        emit Borrow(params.pool, params.asset, params.amount);

        IERC20(params.asset).transfer(owner(), params.amount);
    }

    function repay(IPoolDelegate.CallParams memory params) public onlyOwner {
        uint256 balance = IERC20(params.asset).balanceOf(address(this));
        uint256 maxRepay = borrowed(params);
        params.amount = maxRepay > params.amount ? params.amount : maxRepay;
        // if not enough to repay pull from sender
        if (balance < params.amount) {
            IERC20(params.asset).transferFrom(
                _msgSender(),
                address(this),
                params.amount - balance
            );
        }
        _repay(params);
    }

    function withdraw(IPoolDelegate.CallParams memory params) public onlyOwner {
        _withdraw(params);
        console.log(params.amount);
        uint balance =  _supplied[params.pool][params.asset];
        _supplied[params.pool][params.asset] = params.amount > balance ? 0 : balance - params.amount;

        IERC20(params.asset).transfer(owner(), params.amount);
    }

    function supplied(IPoolDelegate.CallParams memory params)
        public
        view
        returns (uint256)
    {
        address token = _configProvider.getATokenFor(params.pool, params.asset);
        return IERC20(token).balanceOf(address(this));
    }

    function borrowed(IPoolDelegate.CallParams memory params)
        public
        view
        returns (uint256)
    {
        address token = _configProvider.getVTokenFor(params.pool, params.asset);
        return IERC20(token).balanceOf(address(this));
    }

    function withdrawExcesses(IPoolDelegate.CallParams[] memory params) public {
        uint256 loops = params.length;
        for (uint256 i; i < loops; ++i) {
            params[i].amount = getExcess(params[i]);
            _withdraw(params[i]);
        }
    }

    /**
     * @notice Get excess amount in the pool (currentAmount - originalAmount)
     */
    function getExcess(IPoolDelegate.CallParams memory params)
        public
        view
        returns (uint256)
    {
        uint256 balance = supplied(params);
        uint256 suppliedToVault = _supplied[params.pool][params.asset];
        return balance >= suppliedToVault ? balance - suppliedToVault : 0;
    }

    function transfer(
        address asset,
        uint256 amount,
        address to
    ) public onlyOwner {
        uint256 balance = IERC20(asset).balanceOf(address(this));
        IERC20(asset).transfer(to, amount > balance ? balance : amount);
    }

    function _withdraw(IPoolDelegate.CallParams memory params) internal {
        uint256 balance = supplied(params);
        params.amount = balance > params.amount ? params.amount : balance;
        bytes memory data = abi.encodeWithSignature(
            "withdraw((address,address,uint256))",
            params
        );
        _configProvider.getPoolDelegate(params.pool).functionDelegateCall(
            data,
            "Vault: Failed to withdraw"
        );
        emit Withdraw(params.pool, params.asset, params.amount);
    }

    function _repay(IPoolDelegate.CallParams memory params) internal {
        if (_currentDebtPool == address(0)) {
            return;
        }
        bytes memory data = abi.encodeWithSignature(
            "repay((address,address,uint256))",
            params
        );
        _configProvider.getPoolDelegate(params.pool).functionDelegateCall(
            data,
            "Vault: Failed to repay"
        );

        if (borrowed(params) == 0) {
            _currentDebtPool = address(0);
            _currentDebtAsset = address(0);
        }
        emit Repay(params.pool, params.asset, params.amount);
    }
}
