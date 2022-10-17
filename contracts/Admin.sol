// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

/**
* @title Admin Contract.
* @author Anthony (fps) https://github.com/0xfps.
* @dev Admin Contract.
*/
contract Admin {
    /// @dev Owner address for specific calls.
    address private owner;

    /// @dev Set owner on deployment.
    constructor() {
        owner = msg.sender;
    }

    /// @dev Add's an NFT address to blacklist.
    /// @param _tyche   Address of the tyche contract.
    /// @param _nft     NFT contract address.
    function adminAddToBlacklist(address _tyche, address _nft) public {
        /// @dev Ensure that caller is owner.
        require(msg.sender == owner, "!Owner.");

        /// @dev Use call to send address to blacklist
        (bool sent, ) = _tyche.call(
            abi.encodeWithSignature(
                "addToBlacklist(address)",
                _nft
            )
        );

        sent; //Unused.
    }

    /// @dev Removes an NFT address from blacklist.
    /// @param _tyche   Address of the tyche contract.
    /// @param _nft     NFT contract address.
    function adminRemoveToBlacklist(address _tyche, address _nft) public {
        /// @dev Ensure that caller is owner.
        require(msg.sender == owner, "!Owner.");

        /// @dev Use call to send address to blacklist
        (bool sent, ) = _tyche.call(
            abi.encodeWithSignature(
                "removeFromBlacklist(address)",
                _nft
            )
        );

        sent; // Unused.
    }
}