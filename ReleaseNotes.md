# MWS DApp Release Notes - v1.0.0

## Release Date: July 1, 2025

Welcome to the inaugural release of the Multi Wallet Sender (MWS) DApp! This version marks a significant milestone, bringing a powerful and intuitive tool for managing and sending cryptocurrency across multiple wallets and networks. MWS DApp is built with a strong focus on decentralization, user experience, and security, ensuring your transactions are handled efficiently and transparently.

### ✨ New Features & Enhancements

* **Project Setup & Code Review**: The project has undergone a thorough review, resulting in a clean, maintainable code structure. All common widgets are now consolidated into a central `lib/widgets/` folder, ensuring no duplication and improved maintainability. GetX usage and StatelessWidget implementations have been properly structured.
* **UI/UX Enhancements (Inspired by bagguild.com)**:

  * **Splash Screen**: Extended duration for a smoother transition, with updated text to "MWS DApp".
  * **Main Screen**: Features a centered logo with "MWS DApp" text below, styled with a gradient background, rounded corners, and subtle shadow effects for a modern look.
  * **Enhanced Buttons**: Introduced new button components with subtle hover effects and animations, providing a more interactive user experience.
  * **Wallet Cards**: Implemented smooth hover animations and visual feedback for wallet selection.
  * **Typography**: Ensured consistent use of the Montserrat font throughout the application for a cohesive and professional appearance.
  * **Color Scheme**: Adopted a dark theme with purple accents, drawing inspiration from bagguild.com, for a sleek and modern aesthetic.
* **WalletConnect & Wallet UI**:

  * **Comprehensive Wallet Support**: Clearly displays and supports major wallets including MetaMask, Trust Wallet, Coinbase Wallet, Ledger (via WalletConnect), and Phantom (for Solana), each with their respective logos.
  * **Responsive Dialogs**: All wallet connection modals are responsive, adapting seamlessly to desktop, tablet, and mobile views.
  * **Balance Display**: Implemented real-time wallet balance display after connection, with dynamic updates when switching networks. Features a beautiful animated balance card.
  * **Currency Selection**: Added multi-token support (ETH, USDC, USDT, DAI, BNB, CAKE) with network-specific token lists and dynamic token dropdowns, each displaying its logo.
  * **Modern & Stylish UI**: Integrated network and token logos into dropdown selections, along with hover effects and smooth animations, providing a polished and professional feel.
* **Smart Amount Input Field**:

  * **Token-Dependent Behavior**: The amount input field is now intelligently editable only when a token is selected.
  * **Dynamic Labeling**: The label for the amount field dynamically updates to show the selected token symbol (e.g., "Amount (USDC)").
  * **Real-time USD Estimation**: Displays an estimated USD value as the user types, providing immediate financial context.
  * **"MAX" Button**: A convenient "MAX" button allows users to quickly fill the amount field with their entire available balance for the selected token.
* **Enhanced Balance Display**:

  * **Token-Specific Balance**: Shows the balance in the context of the selected token.
  * **USD Value Display**: Displays the equivalent USD value below the token balance.
  * **Network-Aware Fetching**: Fetches all available token balances for the selected network, updating in real-time when networks or tokens are switched.
* **Intuitive Transaction Flow & Conditional UI**:

  * **Step-by-Step Progression**: Implemented a logical, step-by-step flow for sending funds, ensuring users select network, token, and addresses before entering the amount.
  * **Conditional Amount Input Placement**: The amount input field and its label are now moved to the bottom, appearing only after addresses have been entered and validated.
  * **Enhanced Send Button Validation**: The "Send" button is disabled until all necessary conditions are met: network selected, token selected, valid addresses entered, and amount specified. This prevents premature submissions and guides the user through the correct flow.
  * **Visual Progress Tracker**: A new visual progress tracker has been integrated into the Send button area, guiding users through the transaction setup steps (Network, Token, Addresses, Amount) and providing clear feedback on completion status.

### 🔐 DApp Identity & Decentralization

* **Confirmed Decentralization**: MWS DApp is confirmed to be completely decentralized, with no backend, no user data storage, and all transactions handled client-side.
* **Comprehensive Documentation**: A `how_mws_works.md` file has been created, explaining the DApp's architecture, emphasizing its decentralized nature, and clarifying that no user data is stored or stolen. It also details how wallet connection and transaction handling work via Web3.
* **Updated `README.md`**: The `README.md` has been updated to highlight the DApp's decentralized nature, provide full project setup instructions, detail the tech stack (Flutter + GetX + Web3Dart), explain wallet connection, and link to the design inspiration from bagguild.com.

### 🐛 Bug Fixes

* **Resolved Italicized Text Issue**: Fixed the issue where the app name "MWS DApp" appeared italicized or rotated, ensuring it is now perfectly straight and centered.
* **Corrected `cardBackground` References**: Addressed compilation errors related to `cardBackground` property references in `token_dropdown.dart`, `conditional_amount_input.dart`, and `send_button.dart` by updating them to `secondaryBackground`.
* **Fixed `_validateAmount` Method Call**: Corrected the `_validateAmount` method call in `conditional_amount_input.dart` to directly update the `amount.value`.

### 🛠️ Technical Improvements

* **Refactored `MultiSendController`**: The controller has been updated to manage `selectedToken`, `tokenBalances`, `tokenUsdValues`, and new validation states (`isNetworkSelected`, `isTokenSelected`, `areAddressesValid`, `isAmountValid`).
* **New Widgets**: Introduced `TokenDropdown` and `ConditionalAmountInput` widgets to encapsulate new UI logic and improve modularity.
* **Enhanced `SendButton` Logic**: The `SendButton` widget now incorporates comprehensive validation logic and a visual progress indicator.

### 🚀 Performance

* Optimized UI rendering for smoother transitions and animations.

### 💡 Known Issues

* Transaction execution is currently simulated. Real Web3 integration for sending funds is a planned future enhancement.

### 🤝 Contributions

We appreciate your continued support and feedback in making MWS DApp a better tool for multi-wallet transactions. Please report any issues or suggestions on our GitHub repository.




# MWS DApp Release Notes - v1.1.0

## ✨ New Features & Enhancements

- **Real-Time Balance Fetching**: Implemented comprehensive balance fetching from blockchain networks (Base, Ethereum, BNB Chain) for native tokens and ERC20 tokens. All mock balance data has been replaced with real-time queries.
- **MAX Button Fix**: The 'MAX' button in the amount input now correctly populates the field with the actual numeric balance, resolving the previous issue of it inserting a string.
- **Automatic Wallet Disconnection**: Introduced a robust session management system that automatically disconnects the wallet after 10 minutes of inactivity or when the browser/tab is closed.
- **Session Status Widget**: Added a visual indicator showing the remaining session time, with warnings for expiring sessions and an option to extend the session.
- **Enhanced Security**: Implemented shorter timeouts when the page is hidden and immediate disconnection on browser close for improved security.
- **Improved Address Validation**: The address input now uses `BalanceService` for more robust and accurate Ethereum address validation.

## 🐛 Bug Fixes

- Corrected the `BigInt` division issue in `BalanceService` to ensure accurate token balance calculations.

## 🛠️ Technical Improvements

- **New Services**: Introduced `BalanceService` for blockchain interactions and `SessionService` for comprehensive session management.
- **Updated Controllers**: `MultiSendController` and `WalletConnectController` have been updated to integrate with the new balance and session services.
- **New Widgets**: `SessionStatusWidget` has been added to provide clear session feedback to the user.

## 🚀 Performance Optimizations

- Optimized balance fetching and price data calls for better performance.
- Improved memory management for session timers.

## 🎨 UI/UX Improvements

- Enhanced user experience with real-time balance displays and USD values.
- Clear visual cues for session status and warnings.
- More intuitive and secure workflow for amount input and wallet management.

---

---
