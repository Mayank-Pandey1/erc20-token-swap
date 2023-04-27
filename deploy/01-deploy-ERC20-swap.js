const { network } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");
require("dotenv").config();

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments; //getting variables from deployments object
    const { deployer } = await getNamedAccounts();

    const uniswapRouterAddress = process.env.UNISWAP_ROUTER_ADDRESS;
    const tokenAddress = process.env.TOKEN_ADDRESS;
    const args = [uniswapRouterAddress, tokenAddress];

    const erc20Swap = await deploy("ERC20Swap", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(erc20Swap.address, args);
    }
};

module.exports.tags = ["all", "erc20"];
