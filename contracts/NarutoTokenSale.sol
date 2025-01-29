// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title NarutoTokenSale
 * @dev A token sale contract for exchanging USDT for Naruto tokens at a 1:1 ratio.
 *      This contract allows buyers to purchase Naruto tokens with USDT, 
 *      and the owner can withdraw collected USDT or remaining Naruto tokens.
 */
contract NarutoTokenSale is Ownable, ReentrancyGuard {
    // The Naruto token contract (ERC20)
    IERC20 public narutoToken;

    // The USDT token contract (ERC20)
    IERC20 public usdtToken;

    // Price of one NarutoToken in USDT
    uint256 public tokenPrice;

    /**
     * @dev Emitted when tokens are purchased by a buyer.
     * @param buyer The address of the buyer.
     * @param amount The amount of tokens purchased.
     */
    event TokensPurchased(address indexed buyer, uint256 amount);

    /**
     * @dev Emitted when the owner withdraws USDT from the contract.
     * @param owner The address of the contract owner.
     * @param amount The amount of USDT withdrawn.
     */
    event USDTWithdrawn(address indexed owner, uint256 amount);

    /**
     * @dev Emitted when the owner withdraws Naruto tokens from the contract.
     * @param owner The address of the contract owner.
     * @param amount The amount of Naruto tokens withdrawn.
     */
    event TokensWithdrawn(address indexed owner, uint256 amount);

     /**
     * @dev Emitted when the owner changes the price of Naruto tokens from the contract.
     * @param oldPrice The old price of Naruto tokens.
     * @param newPrice The new price of Naruto tokens.
     */
     event TokenPriceUpdated(uint256 oldPrice, uint256 newPrice);

    /**
     * @dev Initializes the contract with the Naruto token and USDT token addresses.
     * @param _narutoTokenAddress The address of the Naruto token contract.
     * @param _usdtAddress The address of the USDT token contract.
     */
    constructor(
        address _narutoTokenAddress,
        address _usdtAddress
    ) Ownable(msg.sender) {
        require(_narutoTokenAddress != address(0), "Invalid Naruto token address");
        require(_usdtAddress != address(0), "Invalid USDT address");

        narutoToken = IERC20(_narutoTokenAddress);
        usdtToken = IERC20(_usdtAddress);
    }

    /**
     * @dev Allows a user to purchase Naruto tokens with USDT at a 1:1 ratio.
     * @param usdtAmount The amount of USDT to spend.
     * Requirements:
     * - `usdtAmount` must be greater than 0.
     * - Contract must have sufficient Naruto token balance.
     */
    function purchaseTokens(uint256 usdtAmount) external nonReentrant {
        
        require(usdtAmount > 0, "Amount must be greater than 0");
        require(
            narutoToken.balanceOf(address(this)) >= usdtAmount,
            "Insufficient Naruto tokens in contract"
        );

        // Calculate the number of NarutoTokens to be bought
        uint256 tokensToBuy = usdtAmount / tokenPrice;

        // Transfer USDT from buyer to contract
        require(
            usdtToken.transferFrom(msg.sender, address(this), usdtAmount),
            "USDT transfer failed"
        );

        // Transfer Naruto tokens to buyer (1:1 ratio)
        require(
            narutoToken.transfer(msg.sender, tokensToBuy),
            "Naruto token transfer failed"
        );

        emit TokensPurchased(msg.sender, tokensToBuy);
    }

    /**
 * @dev Update the price of NarutoTokens in terms of USDT
 * @param newPrice New price of one NarutoToken in USDT
 */
function updatePrice(uint256 newPrice) external onlyOwner {
    require(newPrice > 0, "Price must be greater than zero");
    uint256 oldPrice = tokenPrice;
    tokenPrice = newPrice;
    emit TokenPriceUpdated(oldPrice, newPrice);
}

    /**
     * @dev Allows the owner to withdraw USDT collected in the contract.
     * @param amount The amount of USDT to withdraw.
     * Requirements:
     * - `amount` must be greater than 0.
     * - Contract must have sufficient USDT balance.
     */
    function withdrawUSDT(uint256 amount) external onlyOwner nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(
            usdtToken.balanceOf(address(this)) >= amount,
            "Insufficient USDT balance"
        );

        require(
            usdtToken.transfer(owner(), amount),
            "USDT withdrawal failed"
        );

        emit USDTWithdrawn(owner(), amount);
    }

    /**
     * @dev Allows the owner to withdraw Naruto tokens remaining in the contract.
     * @param amount The amount of Naruto tokens to withdraw.
     * Requirements:
     * - `amount` must be greater than 0.
     * - Contract must have sufficient Naruto token balance.
     */
    function withdrawNarutoTokens(uint256 amount) external onlyOwner nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(
            narutoToken.balanceOf(address(this)) >= amount,
            "Insufficient Naruto token balance"
        );

        require(
            narutoToken.transfer(owner(), amount),
            "Naruto token withdrawal failed"
        );

        emit TokensWithdrawn(owner(), amount);
    }

    /**
     * @dev Returns the current USDT balance in the contract.
     * @return The USDT balance of the contract.
     */
    function getUSDTBalance() public view returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }

    /**
     * @dev Returns the current Naruto token balance in the contract.
     * @return The Naruto token balance of the contract.
     */
    function getNarutoTokenBalance() public view returns (uint256) {
        return narutoToken.balanceOf(address(this));
    }
}
