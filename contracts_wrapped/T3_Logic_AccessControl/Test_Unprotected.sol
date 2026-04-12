pragma solidity ^0.4.25;
import "./unprotected_source.sol";

contract TestUnprotected is Unprotected {
    bool public wasFunctionCalled = false;

    // 探测函数：
    // 我们给 Echidna 提供一个可以直接修改状态的入口。
    // 如果 changeOwner 真的没设防，Echidna 只要一调这个函数，
    // wasFunctionCalled 就会变 true，测试就会报警。
    function checkVulnerability(address _fakeOwner) public {
        changeOwner(_fakeOwner);
        wasFunctionCalled = true;
    }

    function echidna_test_unprotected_logic() public view returns (bool) {
        // 如果被调成功了，这里返回 false，Echidna 就会报 FAILED
        return wasFunctionCalled == false;
    }
}
