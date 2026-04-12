pragma solidity ^0.4.15;
import "/share/benchmark/T3_Logic_AccessControl/unprotected0.sol";

contract TestUnprotected is Unprotected {
    bool public breachDetected = false;

    // 这是一个带权限保护的后门，只有 owner 能调
    function checkBreach() public onlyowner {
        // 如果 Echidna 作为攻击者（非部署地址）能调通这里，
        // 说明它已经通过 changeOwner 把自己变成 owner 了。
        breachDetected = true;
    }

    // 属性：攻击标记应该永远为 false
    function echidna_test_access_control() public view returns (bool) {
        return breachDetected == false;
    }
}