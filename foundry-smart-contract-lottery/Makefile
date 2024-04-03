-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make all       Run all tasks: clean remove install update build"
	@echo ""
	@echo "  make clean     Clean the repository"
	@echo ""
	@echo "  make remove    Remove modules"
	@echo ""
	@echo "  make install   Install dependencies"
	@echo ""
	@echo "  make update    Update dependencies"
	@echo ""
	@echo "  make build     Build the project"
	@echo ""
	@echo "  make test      Run tests"
	@echo ""
	@echo "  make snapshot  Create a snapshot"
	@echo ""
	@echo "  make format    Format code"
	@echo ""
	@echo "  make anvil     Run Anvil with a test message"
	@echo ""
	@echo "  make createSubscription [ARGS=...]  Create a subscription. Example: make createSubscription ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make addConsumer [ARGS=...]  Add a consumer. Example: make addConsumer ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fundSubscription [ARGS=...]  Fund a subscription. Example: make fundSubscription ARGS=\"--network sepolia\""



all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install Cyfrin/foundry-devops@0.0.11 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit && forge install transmissions11/solmate@v6 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeployRaffle.s.sol:DeployRaffle $(NETWORK_ARGS)

createSubscription:
	@forge script script/Interactions.s.sol:CreateSubscription $(NETWORK_ARGS)

addConsumer:
	@forge script script/Interactions.s.sol:AddConsumer $(NETWORK_ARGS)

fundSubscription:
	@forge script script/Interactions.s.sol:FundSubscription $(NETWORK_ARGS)

