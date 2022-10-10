// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

/**
* @title Guard Contract.
* @author Anthony (fps) https://github.com/0xfps.
*/
abstract contract Guard {
    bool locked;
    
    modifier noReentrance {
        require(!locked, "Locked");
        locked = true;
        _;
        locked = false;
    }
}