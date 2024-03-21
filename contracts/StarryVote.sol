// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StarryVote is Pausable, Initializable, OwnableUpgradeable {
	mapping(address => uint256) private lastVoteDate;
	mapping(string => uint256) votesForBot;
	mapping(address => uint256) userVoteTimes;

	uint256 private maxConsecutiveDays;
	uint256 private voteInterval = 86400;
	uint256 private maxVoteTimesPerDay = 5;

	event VoteForBot(address indexed user, string botId);

	function initialize() public initializer {
		__Context_init_unchained();
		__Ownable_init_unchained();
	}

	constructor() {}

	function _getStartOfDay() public view returns (uint256) {
		return block.timestamp / 86400 * 86400;
	}

	function setMaxVoteTimes(uint256 value) external onlyOwner {
		maxVoteTimesPerDay = value;
	}

	function vote(string memory botId) external whenNotPaused {
		uint256 todayVoteTimes = getVoteNumberToday(msg.sender);
		require(todayVoteTimes < 5, "Vote over max times");

		lastVoteDate[msg.sender] = block.timestamp;
		userVoteTimes[msg.sender] = todayVoteTimes + 1;
		votesForBot[botId] += 1;

		emit VoteForBot(msg.sender, botId);
	}

	function _msgSender() internal view override(Context, ContextUpgradeable) returns (address sender) {
		sender = Context._msgSender();
	}

	function _msgData() internal view override(Context, ContextUpgradeable) returns (bytes memory) {
		return Context._msgData();
	}

	function pause() external onlyOwner {
		_pause();
	}

	function unpause() external onlyOwner {
		_unpause();
	}

	function isLastVoteIsToday(address user) public view returns (bool) {
		uint256 currentTime = block.timestamp;
		uint256 startOfToday = _getStartOfDay();
		return lastVoteDate[user] >= startOfToday;
	}

	function getVoteNumber(string memory botId) public view returns(uint256) {
		return votesForBot[botId];
	}

	function getVoteNumberToday(address user) public view returns (uint256) {
		if (isLastVoteIsToday(user)) {
			return userVoteTimes[user];
		}
		return 0;
	}
}
