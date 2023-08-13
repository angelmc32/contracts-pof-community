//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// Useful for debugging. Remove when deploying to a live network.
import "hardhat/console.sol";

// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SoulboundMembership is
	ERC721,
	ERC721URIStorage,
	ERC721Burnable,
	Ownable
{
	using Counters for Counters.Counter;
	address payable public withdrawFundsAddress;
	string public baseURI;
	uint256 public mintCost = 777 * 10 ** 11;

	Counters.Counter private _tokenIdCounter;

	constructor(
		string memory name_,
		string memory symbol_,
		string memory baseURI_,
		address withdrawFundsAddress_
	) ERC721(name_, symbol_) {
		withdrawFundsAddress = payable(withdrawFundsAddress_);
		baseURI = baseURI_;
	}

	function safeMint(address to, string memory uri) public payable {
		require(balanceOf(to) == 0, "ERR: Max balance reached");
		require(msg.value >= mintCost, "ERR: Mint cost is 0.0000777 ETH");
		uint256 tokenId = _tokenIdCounter.current();
		_tokenIdCounter.increment();
		_safeMint(to, tokenId);
		_setTokenURI(tokenId, uri);
	}

	function withdraw(uint _amount) external {
		address sender = _msgSender();
		require(sender == withdrawFundsAddress, "caller is not owner");
		payable(sender).transfer(_amount);
	}

	function getBalance() external view returns (uint) {
		return address(this).balance;
	}

	function _baseURI() internal view override returns (string memory) {
		return baseURI;
	}

	function _burn(
		uint256 tokenId
	) internal override(ERC721, ERC721URIStorage) {
		super._burn(tokenId);
	}

	function tokenURI(
		uint256 tokenId
	) public view override(ERC721, ERC721URIStorage) returns (string memory) {
		return super.tokenURI(tokenId);
	}

	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 tokenId,
		uint256 batchSize
	) internal override(ERC721) {
		require(from == address(0), "Err: token transfer is BLOCKED");
		super._beforeTokenTransfer(from, to, tokenId, batchSize);
	}

	function supportsInterface(
		bytes4 interfaceId
	) public view override(ERC721) returns (bool) {
		return super.supportsInterface(interfaceId);
	}

	receive() external payable {}

	fallback() external payable {}
}
