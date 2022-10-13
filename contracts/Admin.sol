// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

/**
* @title Admin Contract.
* @author Anthony (fps) https://github.com/0xfps.
* @dev Admin Contract.
*/
contract Admin {
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    function adminAddToBlacklist(address _tyche, address _nft) public {
        require(msg.sender == owner, "!Owner.");
        (bool sent, ) = _tyche.call(
            abi.encodeWithSignature(
                "addToBlacklist(address)",
                _nft
            )
        );

        sent;
    }
}