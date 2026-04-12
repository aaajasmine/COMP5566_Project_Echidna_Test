import "./makina_machine_vuln.sol";
contract EchidnaTest is Machine {
    uint256[] public data;
    constructor() { data.push(100); }
    // 评估属性：writeUnchecked 不应篡改非目标区域的内存
    function test_write(uint256 idx, uint256 val) public {
        writeUnchecked(data, idx, val);
    }
    function echidna_array_integrity() public view returns (bool) {
        return data.length == 1 && data[0] == 100;
    }
}
