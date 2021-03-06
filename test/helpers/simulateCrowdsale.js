var LifCrowdsale = artifacts.require('./LifCrowdsale.sol');
var latestTime = require('./latestTime');
var { increaseTimeTestRPC, increaseTimeTestRPCTo } = require('./increaseTime');

/**
 * Generates a crowdsale which funds the first five accounts of param `accounts` with
 * Lif tokens. From the LifToken repo - more usage examples at test/LifToken.js there.
 * @param  {Number} rate     
 * @param  {Array}  balances  
 * @param  {Array}  accounts  
 * @param  {Number} weiPerUSD 
 * @return {Instance} Crowdsale contract
 * @example
 *  const rate = 100000000000;
    const crowdsale = await help.simulateCrowdsale(rate, [40,30,20,10,0], accounts, 1);
    const token = LifToken.at(await crowdsale.token.call());
    balance = await token.balanceOf(account[0]);
    .... Balances ....
    account[0]: 7200000000000000000
    Account[1]: 40000000000000000000
    Account[2]: 30000000000000000000
    Account[3]: 20000000000000000000
    Account[4]: 10000000000000000000
 */
async function simulateCrowdsale(rate, balances, accounts, weiPerUSD) {
    await increaseTimeTestRPC(1);
    var startTime = latestTime() + 5;
    var endTime = startTime + 20;

    var crowdsale = await LifCrowdsale.new(
      startTime+3, startTime+15, endTime,
      rate, rate+10, 1,
      accounts[0], accounts[1],
    );
  
    await increaseTimeTestRPCTo(latestTime()+1);
    await crowdsale.setWeiPerUSDinTGE(weiPerUSD);
    await increaseTimeTestRPCTo(startTime+3);
    for(let i = 0; i < 5; i++) {
      if (balances[i] > 0)
        await crowdsale.sendTransaction({ value: web3.toWei(balances[i]/rate, 'ether'), from: accounts[i + 1]});
    }
    await increaseTimeTestRPCTo(endTime+1);
    await crowdsale.finalize();
    return crowdsale;
}

module.exports = simulateCrowdsale;

