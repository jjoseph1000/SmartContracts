var VoteToken = artifacts.require("./VoteToken.sol");
var VoteSession = artifacts.require("./VoteSession.sol");
var VoteSessionBroadRidge = artifacts.require("./VoteSessionBroadRidge.sol");
var VotingToken = artifacts.require("./VotingToken.sol");
var ScoreStore = artifacts.require("./ScoreStore.sol");
module.exports = function(deployer) {
  deployer.deploy(VoteSession);
};
