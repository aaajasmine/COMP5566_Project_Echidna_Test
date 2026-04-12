
pragma solidity 0.4.25;
import "../../benchmark/T1_Reentrancy/reentrancy_cross_function.sol";

contract EchidnaTest is Reentrancy_cross_function {
    // 构造函数：存入 1 eth 初始资金，这样如果被抽干，判定就会失败
    constructor() public payable {}

    // 核心判定：合约余额应该大于 0。
    // 如果重入攻击成功将钱抽干，此函数返回 false，Echidna 会报告漏洞（falsified）。
    function echidna_test_reentrancy() public view returns (bool) {
        return address(this).balance > 0;
    }
}
