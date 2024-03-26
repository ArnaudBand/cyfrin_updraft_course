// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract RaffleTest is Test {
    event EnteredRaffle(address indexed player);

    Raffle raffle;
    HelperConfig helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        (entranceFee, interval, vrfCoordinator, gasLane, subscriptionId, callbackGasLimit, link) =
            helperConfig.activeNetworkConfig();
        vm.deal(PLAYER, STARTING_USER_BALANCE);
    }

    function testRaffleInitializeInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    ////////////////////
    /// ENTER RAFFLE ///
    ///////////////////

    function testRaffleRevertsWhenYouDontPayEnough() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }

    function testEmitsEventOnEntrance() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    modifier raffleEnteredAndTimePassed() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testCantEnterWhenRaffleIsCalcutating() public raffleEnteredAndTimePassed {
        raffle.performUpKeep("");
        vm.expectRevert(Raffle.Raffle__NotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testCheckUpKeepReturnsFalseIfHasNotBalance() public {
        // Arrange
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        // Act
        (bool upKeepNeeded,) = raffle.checkUpKeep("");
        // Assert
        assert(!upKeepNeeded);
    }

    function testCheckUpKeepReturnFalseIfRaffleNotOpen() public raffleEnteredAndTimePassed {
        raffle.performUpKeep("");
        (bool upKeepNeeded,) = raffle.checkUpKeep("");
        assert(!upKeepNeeded);
    }

    //Challenges

    //      - testCheckUpkeepReturnsFalseIfEnoughTimeHasntPassed ✅
    //      - testCheckUpKeepReturnsTrueWhenParamsAreGood ✅

    function testCheckUpKeepReturnsFalseIfEnoughTimeHasNtPassed() public {
        vm.warp(block.timestamp + interval - 1);
        vm.roll(block.number + 1);
        (bool upKeepNeeded,) = raffle.checkUpKeep("");
        assert(!upKeepNeeded);
    }

    function testCheckUpKeepReturnsTrueWhenParamsAreGood() public raffleEnteredAndTimePassed {
        (bool upKeepNeeded,) = raffle.checkUpKeep("");
        assert(upKeepNeeded == true);
    }

    function testPerformUpKeepCanOnlyRunIfCheckUpKeepIsTrue() public raffleEnteredAndTimePassed {
        raffle.performUpKeep("");
    }

    function testPerformUpkeepRevertsIfCheckUpKeepIsFalse() public {
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        uint256 raffleState = 0;
        vm.expectRevert(
            abi.encodeWithSelector(Raffle.Raffle__UpKeepNotNeeded.selector, currentBalance, numPlayers, raffleState)
        );
        raffle.performUpKeep("");
    }

    function testPerformUpKeepUpdatesRaffleStateAndEmitsRequestId() public raffleEnteredAndTimePassed {
        vm.recordLogs();
        raffle.performUpKeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        Raffle.RaffleState rRaffle = raffle.getRaffleState();

        assert(uint256(requestId) > 0);
        assert(uint256(rRaffle) == 1);
    }
}
