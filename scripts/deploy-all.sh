pwd

npx hardhat run scripts/deploy/0_deploy_delegates.js --network localhost >> .env

npx hardhat run scripts/deploy/1_deploy_config_provider.js --network localhost >> .env

npx hardhat run scripts/deploy/2_deploy_requester.js --network localhost >> .env

npx hardhat run scripts/deploy/3_deploy_vault_generator.js --network localhost >> .env


cat .env | awk 'length {print "V_"$0}' > ./client/.env
