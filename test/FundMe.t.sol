// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;
    
    address USER = makeAddr("user");
    uint256 public constant SEND_VALUE = 0.1 ether;

    function setUp() external {
        DeployFundMe depolyFundMe = new DeployFundMe();
        fundMe = depolyFundMe.run();
        vm.deal(USER, 100e18);

    }

    function testMinimumDollarisFive() view public{
        assertEq(fundMe.MINIMUM_USD(),5e18);
    }

    function testOwner() view public{
        console.log(msg.sender);
        console.log(address(this)); 
        assertEq(fundMe.getOwner(), msg.sender);
    }
 
    function testPriceFeedVersion() view public {
        uint256 version = fundMe.getVersion();
        assertEq(version,4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundWithETH() public {
        vm.prank(USER);

        fundMe.fund{value:10e18}();
        assertEq(fundMe.getAddressToAmountFunded(USER), 10e18);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawFromASingleFunder() public funded {

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }


}