pragma solidity  ^0.8.7;

import '@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol';
import '@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol';
import '@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol';


error Raffle__NotEnoughETHEntered();
error Transfer_Failed();
error Raffle_NotOpen();
error Raffle_UpKeepNotNeeded(uint256 currentBalance,uint256 numPlayers,uint256 raffleState);

abstract contract  Raffle is VRFConsumerBaseV2,KeeperCompatibleInterface{

	enum RaffleState{
		OPEN,
		CALCULATING
	}

	uint256 private immutable i_entranceFee;
	address payable[] private s_players;
	event RaffleEnter(address indexed player);
	event RequestedRaffleWinner(uint256 indexed requestId);
	event WinnerPicked(address indexed winner);

	VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
	bytes32 private immutable i_gasLane;
	uint64 private immutable i_subscriptionid;
	uint32 private immutable i_callbackGasLimit;
	uint16 private constant REQUEST_CONFIRMATIONS=3;
	uint32 private constant NUM_WORDS=1;


	address private s_recentWinner;
	RaffleState private s_raffleState;
	uint256 private immutable s_lastTimeStamp;
	uint256 private immutable i_interval;
	
	constructor(address vrfCoordinatorV2,uint256 entranceFee,bytes32 gasLane,uint64 subscriptionid,uint32 callBackGasLimit,uint256 interval) 
	VRFConsumerBaseV2(vrfCoordinatorV2){
		i_entranceFee=entranceFee;
		i_vrfCoordinator=VRFCoordinatorV2Interface(vrfCoordinatorV2);
		i_gasLane=gasLane;
		i_subscriptionid=subscriptionid;
		i_callbackGasLimit=callBackGasLimit;
		s_raffleState=RaffleState.OPEN;
		s_lastTimeStamp=block.timestamp;
		i_interval=interval;
	}

	function enterRaffle() public payable{
		if(msg.value<i_entranceFee){
			revert Transfer_Failed();
		}
		if(s_raffleState !=RaffleState.OPEN){
			revert Raffle_NotOpen();
		}
		s_players.push(payable(msg.sender));
		emit RaffleEnter(msg.sender);
	}

	function checkUpkeep(bytes memory /* checkData */) public view override 
	returns (bool upKeepNeeded,bytes memory)
	{
		bool isOpen=(RaffleState.OPEN==s_raffleState);
		bool timePassed=((block.timestamp-s_lastTimeStamp)>i_interval);
		bool hasPlayer=(s_players.length>0);
		bool hasBalance=address(this).balance>0;
	   bool upKeepNeeded=(isOpen && timePassed && hasPlayer && hasBalance);
	}

	// function performUpKeep(bytes calldata /*perform Data*/) external override{
	// 	(bool upKeepNeeded,)=checkUpkeep(" ");
	// 	if(!upKeepNeeded){
	// 		return Raffle_UpKeepNotNeeded(address(this).balance,s_players.length,uint256(s_raffleState));
	// 	}
	// 	s_raffleState=RaffleState.CALCULATING;
	// 	uint256 requestId=i_vrfCoordinator.requestRandomWords(
	// 		i_gasLane,
	// 		i_subscriptionid,
	// 		REQUEST_CONFIRMATIONS,
	// 		i_callbackGasLimit,
	// 		NUM_WORDS
	// 	);
	// 	emit RequestedRaffleWinner(requestId);
	// }

	 function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        // require(upkeepNeeded, "Upkeep not needed");
        if (!upkeepNeeded) {
            revert Raffle_UpKeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionid,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedRaffleWinner(requestId);
    }

	function fulfillRandomWords(uint256,uint256[] memory randomWords) internal override
	{
		uint256 WinnerIndex=randomWords[0] % s_players.length;
		address payable recentWinner=s_players[WinnerIndex];
		s_recentWinner=recentWinner;
		s_raffleState=RaffleState.OPEN;
		s_players=new address payable[](0);
		(bool success, )=recentWinner.call{value:address(this).balance}("");
		if(!success){
			// revert Raffle_TransferFailed();
		}
		emit WinnerPicked(recentWinner);
	}

	function getEntranceFee() public view returns (uint256){
		return i_entranceFee;
	}

	function getPlayer(uint256 index) public view returns(address){

	}

	function getRecentWinner() public view returns(address){
		return s_recentWinner;
	}

	function getRaffleState() public view returns (RaffleState){
		return s_raffleState;
	}

	function getNumWords()public view returns(uint256){
		return NUM_WORDS;
	}

}