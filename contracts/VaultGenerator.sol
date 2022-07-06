// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Vault.sol";

contract VaultGenerator is Ownable {
    event VaultCreated(address indexed owner, address vault);

    address internal _feesCollector;
    address internal _configProvider;
    address internal _swapper;

    mapping(address => address[]) internal vaults;

    constructor(
        address swapper_,
        address feesCollector_,
        address configProvider_
    ) {
        _swapper = swapper_;
        _configProvider = configProvider_;
        _feesCollector = feesCollector_;
    }

    function createVault(string calldata name_) public {
        Vault newVault = new Vault(
            name_,
            _swapper,
            _feesCollector,
            _configProvider
        );
        newVault.transferOwnership(_msgSender());
        vaults[_msgSender()].push(address(newVault));
        emit VaultCreated(_msgSender(), address(newVault));
    }

    function getAccountVaults(address account)
        public
        view
        returns (address[] memory)
    {
        return vaults[account];
    }
}
