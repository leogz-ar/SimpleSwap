// 
// ██╗     ███████╗ ██████╗  ██████╗ ███████╗
// ██║     ██╔════╝██╔═══██╗██╔════╝ ╚══███╔╝
// ██║     █████╗  ██║   ██║██║  ███╗  ███╔╝ 
// ██║     ██╔══╝  ██║   ██║██║   ██║ ███╔╝  
// ███████╗███████╗╚██████╔╝╚██████╔╝███████╗
// ╚══════╝╚══════╝ ╚═════╝  ╚═════╝ ╚══════╝
// SPDX-License-Identifier: MIT
/** @notice Solidity compiler version */
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
* @title SimpleSwapLeo
* @notice This contract allows users to provide and remove liquidity, 
* and swap between two ERC20 tokens
*/
contract SimpleSwapLeo {
    mapping(address => mapping(address => uint256)) public reserves;
    mapping(address => mapping(address => mapping(address => uint256))) public liquidity;
/**
* @notice Add liquidity to the pool
*/
/**
 * @notice Add liquidity to the pool
 * @param tokenA Address of token A
 * @param tokenB Address of token B
 * @param amountADesired Desired amount of token A
 * @param amountBDesired Desired amount of token B
 * @param amountAMin Minimum acceptable amount of token A
 * @param amountBMin Minimum acceptable amount of token B
 * @param to Recipient of liquidity tokens
 * @param deadline Expiration time of the transaction
 */
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidityMinted) {
        require(block.timestamp <= deadline, "Transaction expired");

        (uint reserveA, uint reserveB) = (reserves[tokenA][tokenB], reserves[tokenB][tokenA]);

        if (reserveA == 0 && reserveB == 0) {
            amountA = amountADesired;
            amountB = amountBDesired;
        } else {
            uint amountBOptimal = (amountADesired * reserveB) / reserveA;
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "Insufficient B amount");
                amountA = amountADesired;
                amountB = amountBOptimal;
            } else {
                uint amountAOptimal = (amountBDesired * reserveA) / reserveB;
                require(amountAOptimal >= amountAMin, "Insufficient A amount");
                amountA = amountAOptimal;
                amountB = amountBDesired;
            }
        }

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        reserves[tokenA][tokenB] += amountA;
        reserves[tokenB][tokenA] += amountB;

        liquidity[tokenA][tokenB][to] += amountA + amountB;

        liquidityMinted = amountA + amountB;
    }

/**
* @notice Remove liquidity from the pool
*/
/**
 * @notice Remove liquidity from the pool
 * @param tokenA Address of token A
 * @param tokenB Address of token B
 * @param liquidityAmount Amount of liquidity to remove
 * @param amountAMin Minimum acceptable amount of token A
 * @param amountBMin Minimum acceptable amount of token B
 * @param to Recipient of tokens
 * @param deadline Expiration time of the transaction
 */
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidityAmount,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB) {
        require(block.timestamp <= deadline, "Transaction expired");

        uint userLiquidity = liquidity[tokenA][tokenB][msg.sender];
        require(userLiquidity >= liquidityAmount, "Not enough liquidity");

        uint reserveA = reserves[tokenA][tokenB];
        uint reserveB = reserves[tokenB][tokenA];

        amountA = (liquidityAmount * reserveA) / userLiquidity;
        amountB = (liquidityAmount * reserveB) / userLiquidity;

        require(amountA >= amountAMin, "Too little A");
        require(amountB >= amountBMin, "Too little B");

        reserves[tokenA][tokenB] -= amountA;
        reserves[tokenB][tokenA] -= amountB;

        liquidity[tokenA][tokenB][msg.sender] -= liquidityAmount;

        IERC20(tokenA).transfer(to, amountA);
        IERC20(tokenB).transfer(to, amountB);
    }

/**
* @notice Swap exact tokens for tokens
*/
/**
 * @notice Swap an exact amount of input tokens for output tokens
 * @param amountIn Exact amount of tokens to input
 * @param amountOutMin Minimum amount of output tokens expected
 * @param path Array of token addresses [tokenIn, tokenOut]
 * @param to Recipient of output tokens
 * @param deadline Expiration time of the transaction
 */
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        require(path.length == 2, "Only direct swaps supported");
        require(block.timestamp <= deadline, "Transaction expired");

        address input = path[0];
        address output = path[1];

        IERC20(input).transferFrom(msg.sender, address(this), amountIn);

        uint reserveIn = reserves[input][output];
        uint reserveOut = reserves[output][input];

/**
 * @notice Calculates how many output tokens you get for a given input
 * @param amountIn Input token amount
 * @param reserveIn Reserve of input token
 * @param reserveOut Reserve of output token
 * @return amountOut Calculated output token amount after 0.3% fee
 */
        uint amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
        require(amountOut >= amountOutMin, "Insufficient output amount");

        reserves[input][output] += amountIn;
        reserves[output][input] -= amountOut;

        IERC20(output).transfer(to, amountOut);

        amounts = new uint[](2);
        amounts[0] = amountIn;
        amounts[1] = amountOut;
    }

/**
* @notice View current price of tokenA in terms of tokenB
*/
/**
 * @notice Get price of tokenA in terms of tokenB
 * @param tokenA Address of token A
 * @param tokenB Address of token B
 * @return price Price of tokenA in terms of tokenB (scaled by 1e18)
 */
    function getPrice(address tokenA, address tokenB) external view returns (uint price) {
        uint reserveA = reserves[tokenA][tokenB];
        uint reserveB = reserves[tokenB][tokenA];
        require(reserveA > 0, "No liquidity");
        price = reserveB * 1e18 / reserveA;
    }

    /**
     * @notice Calculate output amount from input amount and reserves
     */
/**
 * @notice Calculates how many output tokens you get for a given input
 * @param amountIn Input token amount
 * @param reserveIn Reserve of input token
 * @param reserveOut Reserve of output token
 * @return amountOut Calculated output token amount after 0.3% fee
 */
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public pure returns (uint amountOut) {
        require(reserveIn > 0 && reserveOut > 0, "Invalid reserves");
        amountOut = (amountIn * reserveOut) / (reserveIn + amountIn);
    }
}
