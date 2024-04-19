// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script{

    function run() external returns (FundMe){
        HelperConfig helperConfig = new HelperConfig();
        address EthPriceFeed = address(helperConfig.getAnvilEthConfig());

        vm.startBroadcast();
        FundMe fundMe = new FundMe(EthPriceFeed);
        vm.stopBroadcast();
        return fundMe;

    }

}