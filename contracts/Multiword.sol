//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
contract Multiword is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    bytes32 private immutable i_jobId;
    uint256 private fee;

    // multiple params returned in a single oracle response
    uint256 public btc;
    uint256 public usd;
    uint256 public eur;

    event RequestMultipleFulfilled(
        bytes32 indexed requestId,
        uint256 btc,
        uint256 usd,
        uint256 eur
    );

    /**
     * @notice Initialize the link token and target oracle
     * @dev The oracle address must be an Operator contract for multiword response
     *
     *
     * Kovan Testnet details:
     * Link Token: 0xa36085F69e2889c224210F603D836748e7dC0088
     * Oracle: 0x74EcC8Bdeb76F2C6760eD2dc8A46ca5e581fA656 (Chainlink DevRel)
     * jobId: 53f9755920cd451a8fe46f5087468395
     *
     */
    constructor(
        address linkToken,
        address oracle,
        bytes32 jobId
    ) {
        setChainlinkToken(linkToken);
        setChainlinkOracle(oracle);
        i_jobId = jobId;
        fee = 0.1 * 10**18; // (Varies by network and job)
    }

    /**
     * @notice Request mutiple parameters from the oracle in a single transaction
     */
    function requestMultipleParameters() public {
        Chainlink.Request memory req = buildChainlinkRequest(
            i_jobId,
            address(this),
            this.fulfillMultipleParameters.selector
        );
        req.add(
            "urlBTC",
            "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=BTC"
        );
        req.add("pathBTC", "BTC");
        req.add(
            "urlUSD",
            "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD"
        );
        req.add("pathUSD", "USD");
        req.add(
            "urlEUR",
            "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=EUR"
        );
        req.add("pathEUR", "EUR");
        sendChainlinkRequest(req, fee); // MWR API.
    }

    /**
     * @notice Fulfillment function for multiple parameters in a single request
     * @dev This is called by the oracle. recordChainlinkFulfillment must be used.
     */
    function fulfillMultipleParameters(
        bytes32 requestId,
        uint256 btcResponse,
        uint256 usdResponse,
        uint256 eurResponse
    ) public recordChainlinkFulfillment(requestId) {
        emit RequestMultipleFulfilled(
            requestId,
            btcResponse,
            usdResponse,
            eurResponse
        );
        btc = btcResponse;
        usd = usdResponse;
        eur = eurResponse;
    }

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}