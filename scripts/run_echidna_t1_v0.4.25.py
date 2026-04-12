import os
import subprocess

# ================= 配置路径 =================
BASE_DIR = "/share"
CATEGORY = "T1_Reentrancy"
DATASET_DIR = os.path.join(BASE_DIR, "benchmark", CATEGORY)
WRAPPED_DIR = os.path.join(BASE_DIR, "contracts_wrapped", CATEGORY)
RESULTS_DIR = os.path.join(BASE_DIR, "results", CATEGORY)

os.makedirs(WRAPPED_DIR, exist_ok=True)
os.makedirs(RESULTS_DIR, exist_ok=True)

# 0.4.25 版本的模板
TEMPLATE = """
pragma solidity 0.4.25;
import "../../benchmark/{category}/{original_file}";

contract EchidnaTest is {contract_name} {{
    // 构造函数：存入 1 eth 初始资金，这样如果被抽干，判定就会失败
    constructor() public payable {{}}

    // 核心判定：合约余额应该大于 0。
    // 如果重入攻击成功将钱抽干，此函数返回 false，Echidna 会报告漏洞（falsified）。
    function echidna_test_reentrancy() public view returns (bool) {{
        return address(this).balance > 0;
    }}
}}
"""

def get_contract_name(filename):
    mapping = {
        "etherstore.sol": "EtherStore",
        "reentrancy_dao.sol": "ReentrancyDAO",
        "modifier_reentrancy.sol": "ModifierEntrancy",
        "reentrancy_cross_function.sol": "Reentrancy_cross_function"
    }
    return mapping.get(filename.lower())

def run_tests():
    print("--- 开始测试 0.4.25 系列合约 ---")
    # 确保环境中有 0.4.25
    subprocess.run("solc-select install 0.4.25", shell=True)
    
    files = ["etherstore.sol", "reentrancy_dao.sol", "modifier_reentrancy.sol", "reentrancy_cross_function.sol"]
    
    for filename in files:
        full_path = os.path.join(DATASET_DIR, filename)
        if not os.path.exists(full_path): continue
        
        contract_name = get_contract_name(filename)
        wrapped_file = os.path.join(WRAPPED_DIR, f"Test_{filename}")
        
        # 生成测试文件
        with open(wrapped_file, "w") as f:
            f.write(TEMPLATE.format(category=CATEGORY, original_file=filename, contract_name=contract_name))

        print(f"🚀 正在测试: {filename}...")
        result_json = os.path.join(RESULTS_DIR, filename.replace(".sol", ".json"))
        
        # 修正 1：在同一条 shell 命令中切换编译器
        # 修正 2：将 --allow-paths 放入 --solc-args
        # 修正 3：增加足够的测试限制
        cmd = (f"solc-select use 0.4.25 && "
               f"echidna {wrapped_file} --contract EchidnaTest "
               f"--solc-args '--allow-paths {BASE_DIR}' "
               f"--format json --test-limit 50000")
        
        with open(result_json, "w") as out:
            subprocess.run(cmd, shell=True, stdout=out, stderr=subprocess.STDOUT)
        print(f"✅ 完成: {filename}")

if __name__ == "__main__":
    run_tests()