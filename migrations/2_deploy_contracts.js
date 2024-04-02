const AcountManagement = artifacts.require("AcountManagement");

module.exports = function (deployer) {
  deployer.deploy(AcountManagement);
};

