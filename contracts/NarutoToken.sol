// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract NarutoToken is ERC20, Ownable, ERC20Permit, Pausable {
    uint256 public constant MAX_SUPPLY = 10_000_000 * 10**6; // 10 million tokens
    
    // Add an address for the authorized sale contract
    address public saleContract;
    
    event SaleContractUpdated(address indexed previousSale, address indexed newSale);

    constructor(address initialOwner) 
        ERC20("NarutoToken", "NATO") 
        Ownable(initialOwner)
        ERC20Permit("NarutoToken")
    {
        _mint(initialOwner, 1_000_000 * 10**6); // Initial mint of 1 million tokens
    }

    /**
     * @dev Set the authorized sale contract address
     * @param _saleContract Address of the new sale contract
     */
    function setSaleContract(address _saleContract) external onlyOwner {
        require(_saleContract != address(0), "Invalid sale contract address");
        address oldSaleContract = saleContract;
        saleContract = _saleContract;
        emit SaleContractUpdated(oldSaleContract, _saleContract);
    }

    /**
     * @dev Pause token transfers in case of emergency
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause token transfers
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Override transfer function to add pause functionality
     */
    function transfer(address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transfer(to, amount);
    }

    /**
     * @dev Override transferFrom function to add pause functionality
     */
    function transferFrom(address from, address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transferFrom(from, to, amount);
    }

    function mint(address to, uint256 amount) public onlyOwner whenNotPaused {
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
    }

    function remainingMintableSupply() public view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }

    /**
     * @dev Transfer ownership to the sale contract
     * Can only be called once and is irreversible
     */
    function transferOwnershipToSale() external onlyOwner {
        require(saleContract != address(0), "Sale contract not set");
        require(saleContract != owner(), "Already owned by sale contract");
        _transferOwnership(saleContract);
    }
}