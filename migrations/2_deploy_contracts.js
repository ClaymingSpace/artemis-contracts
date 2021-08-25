var ArtemisTreasury = artifacts.require("ArtemisTreasury");

module.exports = function(deployer, network, accounts) {
  if (network === "main") {
    return
  }

  console.log("-----------------------------")
  console.log(accounts)
  console.log("-----------------------------")

  const nations = accounts.slice(0, 3)
  const numConfirmationsRequired = 2

  return deployer.deploy(ArtemisTreasury, nations, numConfirmationsRequired)
};
