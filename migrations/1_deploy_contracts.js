const Auction = artifacts.require("Auction");

module.exports = function(deployer) {
  const args = ["pot", "clay", "toy"];
  deployer.deploy(Auction, args);
};
