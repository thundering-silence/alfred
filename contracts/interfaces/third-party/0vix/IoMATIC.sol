//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Compound/IComptroller.sol";
import "../Compound/ICompToken.sol";

interface IoMATIC is ICompToken {
    function mint() external payable;

    function repayBorrow() external payable;
}
