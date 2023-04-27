//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/** @author Mayank Pandey
 *  @title A contract for swapping ERC20 token and ETH
 *  @notice The contract demonstrates how people can exchange Ether to an arbitrary ERC-20 token
 */

interface IUniswapRouter {
    function WETH() external pure returns (address);

    function swapETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

interface ERC20Swapper {
    /**
     * @dev swaps the `msg.value` Ether to at least `minAmount` of tokens in `address`, or reverts
     * @param token The address of ERC-20 token to swap
     * @param minAmount The minimum amount of tokens transferred to msg.sender
     * @return The actual amount of transferred tokens
     */
    function swapEtherToToken(
        address token,
        uint256 minAmount
    ) external payable returns (uint256);
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

error ERC20Swap__LessTokens();
error ERC20Swap__NoEthers();

contract ERC20Swap is ERC20Swapper {
    IUniswapRouter public uniswapRouter;
    address private s_tokenAddress;

    constructor(address _uniswapRouter, address tokenAddress) {
        uniswapRouter = IUniswapRouter(_uniswapRouter);
        s_tokenAddress = tokenAddress;
    }

    function swapEtherToToken(
        address /*s_tokenAddress */,
        uint256 minAmount
    ) public payable override returns (uint256) {
        if (!(msg.value > 0)) revert ERC20Swap__NoEthers();
        require(s_tokenAddress != address(0), "Invalid token address");

        //ERC20 token contract
        IERC20 erc20 = IERC20(s_tokenAddress);

        //current token balance of the contract
        uint initialTokenBalance = erc20.balanceOf(address(this));

        // setting the Uniswap exchange path
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = s_tokenAddress;

        //swapping ETH to the token using Uniswap
        uniswapRouter.swapETHForTokens{value: msg.value}(
            minAmount,
            path,
            msg.sender,
            block.timestamp + 300
        );

        //actual amount of tokens received
        uint256 tokenAmount = erc20.balanceOf(address(this)) -
            initialTokenBalance;

        if (tokenAmount < minAmount) revert ERC20Swap__LessTokens();

        // transfer the actual token amount to the caller
        require(
            erc20.transfer(msg.sender, tokenAmount),
            "Token transfer failed"
        );

        return tokenAmount;
    }

    function getTokenAddress() public view returns (address) {
        return s_tokenAddress;
    }
}
