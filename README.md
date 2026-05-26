# Chain-Proof-Credential-System
ChainProof: On-Chain Credential System\
📌 Project Overview\
This project is a smart contract-based credentialing system designed to record informal contributions (like open-source work) on the blockchain. It solves the problem of "invisible contributions" by providing a verifiable, non-transferable record of achievement.\
🛠️ Technical Features\
Admin-Only Issuance: Only the deployer can issue credentials.\
Soulbound Logic: Credentials are non-transferable to maintain the integrity of the reputation.\
Trust Score Algorithm: A custom formula that weights both the quantity and the quality (level) of achievements.\
Gated Access: A function accessGranted() that restricts access based on the trust score threshold.\
Duplicate Prevention: Prevents the same credential title from being issued twice to the same user.\
🚀 How to Run\
Open Remix IDE.\
Create a file named ChainProof.sol and paste the code.\
Deploy the contract using the "Deploy & Run Transactions" tab.\
Use the functions to issue credentials and test the accessGranted gate.

