pragma solidity 0.4.25;
import "./unchecked_source.sol";

contract TestReturnValue is ReturnValue {
    bool public wasCalled = false;

    // 关键修正：显式添加 payable 构造函数，让 Echidna 能顺利部署
    constructor() public payable {}

    // 探测函数
    function checkVulnerability(address callee) public {
        callnotchecked(callee);
        wasCalled = true;
    }

    // Echidna 属性：
    // 如果我们传入一个会导致失败的地址（如 0x0），
    // 漏洞函数 callnotchecked 会因为没检查返回值而继续执行，导致 wasCalled 变 true。
    function echidna_test_unchecked_call() public view returns (bool) {
        return wasCalled == false;
    }
}
