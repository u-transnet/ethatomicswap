/**
 * Atomic swap class
 *
 * @author Djenad Razic
 * @company Altcoin Exchange, Inc.
 */
var AtomicSwap;
AtomicSwap = function (configuration, appConfiguration) {
    this.engine = null;

    /**
     * @param configuration
     * @param appConfiguration
     */
    this.construct = function (configuration, appConfiguration) {
        var Engine = require("./engine");
        this.engine = new Engine(configuration, appConfiguration);
        this.engine.common.Extend(this, this.engine);
    };

    this.construct(configuration, appConfiguration);

    /**
     * Initiate atomic swap transfer
     * @param refundTime
     * @param secretHash - Secret hash
     * @param address - Participant address
     * @param amount - Amount to transfer
     * @param extendedParams
     * @constructor
     */
    this.Initiate = function (refundTime, secretHash, address, amount, extendedParams) {
        var conversion = (extendedParams && extendedParams.conversion) ? extendedParams.conversion : 'milliether';

        var params = {
            from: this.appConfig.defaultWallet,
            value: this.web3.utils.toWei(amount, conversion),
            gas: 200000
        };

        this.engine.common.Extend(params, extendedParams, ["conversion"]);
        return this.engine.callFunction("initiate", [refundTime, secretHash, address, 1], params);
    };

    /**
     * Participate to atomic swap transfer
     * @param refundTime
     * @param secretHash - Secret hash
     * @param address - Participant address
     * @param amount
     * @param extendedParams
     */
    this.Participate = function (refundTime, secretHash, address, amount, extendedParams) {
        var conversion = (extendedParams && extendedParams.conversion) ? extendedParams.conversion : 'milliether';

        var params = {
            from: this.appConfig.defaultWallet,
            value: this.web3.utils.toWei(amount, conversion),
            gas: 200000
        };

        this.engine.common.Extend(params, extendedParams, ["conversion"]);
        return this.engine.callFunction("initiate", [refundTime, secretHash, address, 2], params);
    };

    /**
     * Redeem funds with given secret
     * @param secret - Secret hash
     * @param from - address of fund's owner
     * @param extendedParams
     */
    this.Redeem = function (secret, from, extendedParams) {

        var params = {
            from: this.appConfig.defaultWallet,
            gas: 200000
        };

        this.engine.common.Extend(params, extendedParams);
        return this.callFunction("redeem", [secret, from], params);
    };

    /**
     * Refund contract transaction
     * @param secretHash
     * @param to - address of participant of contract
     * @param extendedParams
     */
    this.Refund = function (secretHash, to, extendedParams) {

        var params = {
            from: this.appConfig.defaultWallet,
            gas: 200000
        };

        this.engine.common.Extend(params, extendedParams);
        return this.callFunction("refund", [secretHash, to], params);
    };
};

module.exports = AtomicSwap;