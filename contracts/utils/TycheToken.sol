// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
* @title Tyche Token ($TYCHE).
* @author Anthony (fps) https://github.com/0xfps.
* @dev Tyche Reward ERC20 Token.
*/
contract TycheToken is ERC20 {
    constructor(address _address) ERC20("TycheToken", "$TYCHE") {
        _mint(_address, (1 * 10e9 * (10e18)));
    }
}