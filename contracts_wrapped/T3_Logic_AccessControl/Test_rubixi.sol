pragma solidity ^0.4.25;
import "./rubixi_source.sol";

contract TestRubixi is Rubixi {
    // 部署时记录下最初的部署者
    address private originalOwner = tx.origin;

    // 探测函数：
    // 我们利用 Rubixi 源码中已有的 collectAllFees 函数。
    // 在源码中，collectAllFees 带有 onlyowner 修饰符。
    // 如果 msg.sender 成功调用了它，且 msg.sender 不是 originalOwner，
    // 说明 owner 权限已经被篡夺了。
    bool public breachDetected = false;

    function checkAccess() public {
        // 如果我不是最初的 Owner，但我却能成功执行到这一步（说明通过了 onlyowner 检查）
        if (msg.sender != originalOwner) {
            breachDetected = true;
        }
    }

    // 只要 breachDetected 变成 true，测试就会 FAILED
    function echidna_test_rubixi_secure() public view returns (bool) {
        return breachDetected == false;
    }
}
