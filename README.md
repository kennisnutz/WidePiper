# WidePiper Smart Contracts Development Guide

Welcome to the WidePiper project repository! This guide will help you get started with setting up and running tests for the smart contracts using the Foundry smart contract development framework.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Node.js](https://nodejs.org/) (version 14.x or later)
- [Git](https://git-scm.com/)
- [Foundry](https://github.com/orbs-network/foundry) smart contract development framework

## Setup

1. Clone the repository:

    ```bash
    git clone https://github.com/kennisnutz/WidePiper
    ```

2. Navigate to the root directory of the cloned repository:

    ```bash
    cd WidePiper
    ```

3. Create a `.env` file in the root directory:

    ```bash
    touch .env
    ```

4. Register for an RPC API key for the Ethereum mainnet on [Alchemy](https://alchemy.com/?r=53a351cbb6458a1a) (or any other provider of your choice) and save the API key as `MAINNET_RPC_URL` in the `.env` file:

    ```
    MAINNET_RPC_URL=<your-alchemy-api-key>
    ```

## Running Tests

To run the tests for the WidePiper smart contracts, follow these steps:

1. Ensure you are in the root directory of the repository.

2. Run the tests using the Foundry framework with the following command:

    ```bash
    forge test --fork-url <mainnet-rpc-url>
    ```

   Replace `<mainnet-rpc-url>` with the Ethereum mainnet RPC URL you obtained from Alchemy or your chosen provider.

That's it! You've successfully set up and run tests for the WidePiper smart contracts using the Foundry smart contract development framework.

## Additional Resources

- [WidePiper Project Repository](https://github.com/kennisnutz/WidePiper)
- [Foundry Documentation](https://github.com/orbs-network/foundry)

If you encounter any issues or have questions, feel free to reach out to the WidePiper development team or community for assistance.

Happy coding! 🚀
