// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.19;

contract MoonwellPriceEval {
    mapping (address => uint256) internal prices;
    address public admin;

    constructor() { admin = msg.sender; }

    // 提取自源码：允许管理员覆盖价格
    function setDirectPrice(address asset, uint256 price) public {
        // 漏洞评估点：如果这个函数缺乏足够的权限校验或数值范围限制
        prices[asset] = price;
    }

    function getAssetPrice(address asset) public view returns (uint256) {
        return prices[asset];
    }
}

contract TestMoonwell is MoonwellPriceEval {
    function echidna_stable_price() public view returns (bool) {
        // 评估 Echidna 能否发现价格可以被随意篡改为 0 或极高值
        uint256 p = getAssetPrice(address(0x1));
        return p < 1e36; 
    }
}
