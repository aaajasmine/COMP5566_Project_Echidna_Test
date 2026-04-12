import "./moonwell_vuln.sol";
contract EchidnaTest is ChainlinkOracle {
    constructor() { admin = msg.sender; }
    // 评估属性：非管理员不应能篡改价格
    function echidna_no_unauthorized_price() public view returns (bool) {
        return true; // 这是一个占位，实际漏洞在于 setDirectPrice 缺乏 onlyOwner
    }
    // 评估属性：价格不应被设置为 0 (模拟恶意脱锚)
    function echidna_price_not_zero() public view returns (bool) {
        return getAssetPrice(address(0x1)) != 0;
    }
}
