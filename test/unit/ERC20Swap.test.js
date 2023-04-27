const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { assert, expect } = require("chai");
const { developmentChains } = require("../../helper-hardhat-config");

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("ERC20Swap", () => {
          let erc20Swap;
          let deployer;
          let user;
          beforeEach(async function () {
              deployer = (await getNamedAccounts()).deployer;
              user = (await getNamedAccounts()).deployer;
              //specifying which account we want connected to our deployed contract since we will be making transactions
              //while testing
              await deployments.fixture(["all"]); //using fixture we can deploy our contracts with as many tags as we want
              //running all the deploy scripts using this line

              erc20Swap = await ethers.getContract("ERC20Swap", deployer);
          });

          describe("swapEtherToToken", () => {
              let gasUsed;
              beforeEach(async () => {
                  const etherAmount = ethers.utils.parseEther("1");
                  const minTokenAmount = ethers.utils.parseUnits("1", 18);
                  const tokenAddress = await erc20Swap.getTokenAddress();
                  const tx = await erc20Swap.swapEtherToToken(
                      tokenAddress,
                      minTokenAmount,
                      { value: etherAmount }
                  );

                  const txReceipt = await tx.wait(1);
                  gasUsed = await txReceipt.gasUsed;
              });
              it("ERC20Swap contract received the expected amount of ether", async () => {
                  const contractEtherBalance = await ethers.provider.getBalance(
                      erc20Swap.address
                  );
                  expect(contractEtherBalance).to.equal(etherAmount);
              });

              it("Check that the gas used was reasonable", () => {
                  expect(gasUsed).to.be.lessThan(1000000);
              });
          });
      });
