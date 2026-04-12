pragma solidity ^0.4.18;
import "./lotto_source.sol";

contract BadWinner {
    // 拒收以太币
    function() public payable { revert(); }
}

contract TestLotto is Lotto {
    BadWinner public badWinner;

    constructor() public payable {
        badWinner = new BadWinner();
        winner = address(badWinner); // 预设赢家为恶意合约
        winAmount = 0.5 ether;
    }

    function checkLottoVulnerability() public {
        sendToWinner();
    }

    // Echidna 属性：如果 payedOut 变成了 true，但钱没转出去（余额没减少）
    // 说明 send 失败了但合约认为已经付过钱了
    function echidna_test_lotto_silent_failure() public view returns (bool) {
        if (payedOut && address(this).balance >= 0.5 ether) {
            return false; // 发现漏洞，触发 FAILED
        }
        return true;
    }
}
