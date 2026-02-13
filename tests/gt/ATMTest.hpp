#pragma once

#include <gtest/gtest.h>
#include "ATM.hxx"
#include "Bank.hxx"
#include "BaseDisplay.hxx"

// Simple test fixture without mocking for now
class ATMTest : public ::testing::Test {
protected:
    Bank bank;
    BaseDisplay display;
    ATM atm{&bank, &display};

    void SetUp() override {
        // Add test accounts to bank
        bank.addAccount();
        bank.addAccount();
        bank.addAccount();
    }
};

// Constructor tests
TEST_F(ATMTest, ConstructorInitialization) {
    // Verify ATM can be constructed with Bank and Display pointers
    Bank testBank;
    BaseDisplay testDisplay;
    ATM testAtm(&testBank, &testDisplay);
    // Construction successful if we reach here
    SUCCEED();
}

// viewAccount tests
TEST_F(ATMTest, viewAccountValidAccount) {
    // Account 1 should exist in the bank
    atm.viewAccount(1, "");
    // Should execute without crashing
    SUCCEED();
}

TEST_F(ATMTest, viewAccountInvalidAccount) {
    // Try to access non-existent account 999
    atm.viewAccount(999, "wrong_password");
    // Should display error but not crash
    SUCCEED();
}

TEST_F(ATMTest, viewAccountMultipleAccounts) {
    atm.viewAccount(1, "");
    SUCCEED();
    atm.viewAccount(2, "");
    SUCCEED();
    atm.viewAccount(3, "");
    SUCCEED();
}

// fillUserRequest tests
TEST_F(ATMTest, fillUserRequestBalanceWithoutAccount) {
    // Without setting current account, request should do nothing
    atm.fillUserRequest(UserRequest::REQUEST_BALANCE, 0);
    SUCCEED();
}

TEST_F(ATMTest, fillUserRequestBalanceWithAccount) {
    // Set valid account first
    atm.viewAccount(1, "");
    
    // Now request balance
    atm.fillUserRequest(UserRequest::REQUEST_BALANCE, 0);
    SUCCEED();
}

TEST_F(ATMTest, fillUserRequestDepositWithAccount) {
    atm.viewAccount(1, "");
    atm.fillUserRequest(UserRequest::REQUEST_DEPOSIT, 100.0);
    SUCCEED();
}

TEST_F(ATMTest, fillUserRequestWithdrawWithAccount) {
    atm.viewAccount(1, "");
    atm.fillUserRequest(UserRequest::REQUEST_WITHDRAW, 50.0);
    SUCCEED();
}

TEST_F(ATMTest, fillUserRequestTransactionsWithAccount) {
    atm.viewAccount(1, "");
    
    // Deposit first to have transactions
    atm.fillUserRequest(UserRequest::REQUEST_DEPOSIT, 100.0);
    
    // Then request transactions
    atm.fillUserRequest(UserRequest::REQUEST_TRANSACTIONS, 0);
    SUCCEED();
}

// showBalance test
TEST_F(ATMTest, showBalance) {
    atm.viewAccount(1, "");
    atm.fillUserRequest(UserRequest::REQUEST_BALANCE, 0);
    SUCCEED();
}

// makeDeposit test
TEST_F(ATMTest, makeDeposit) {
    atm.viewAccount(1, "");
    atm.fillUserRequest(UserRequest::REQUEST_DEPOSIT, 250.0);
    SUCCEED();
}

// withdraw test
TEST_F(ATMTest, withdraw) {
    atm.viewAccount(1, "");
    atm.fillUserRequest(UserRequest::REQUEST_WITHDRAW, 75.0);
    SUCCEED();
}

// showTransactions test
TEST_F(ATMTest, showTransactions) {
    atm.viewAccount(1, "");
    
    // Make a deposit to generate transactions
    atm.fillUserRequest(UserRequest::REQUEST_DEPOSIT, 100.0);
    
    // View transactions
    atm.fillUserRequest(UserRequest::REQUEST_TRANSACTIONS, 0);
    SUCCEED();
}

// Multi-step workflow test
TEST_F(ATMTest, CompleteATMWorkflow) {
    // Step 1: Access account
    atm.viewAccount(1, "");
    
    // Step 2: Deposit money
    atm.fillUserRequest(UserRequest::REQUEST_DEPOSIT, 500.0);
    
    // Step 3: Check balance
    atm.fillUserRequest(UserRequest::REQUEST_BALANCE, 0);
    
    // Step 4: Withdraw money
    atm.fillUserRequest(UserRequest::REQUEST_WITHDRAW, 100.0);
    
    SUCCEED();
}

// Test with multiple accounts
TEST_F(ATMTest, SwitchBetweenAccounts) {
    // Access account 1
    atm.viewAccount(1, "");
    atm.fillUserRequest(UserRequest::REQUEST_DEPOSIT, 100.0);
    
    // Switch to account 2
    atm.viewAccount(2, "");
    atm.fillUserRequest(UserRequest::REQUEST_DEPOSIT, 200.0);
    
    // Switch back to account 1
    atm.viewAccount(1, "");
    atm.fillUserRequest(UserRequest::REQUEST_BALANCE, 0);
    
    SUCCEED();
}

// Test rapid transactions
TEST_F(ATMTest, RapidTransactions) {
    atm.viewAccount(1, "");
    
    // Multiple deposits
    for (int i = 0; i < 3; i++) {
        atm.fillUserRequest(UserRequest::REQUEST_DEPOSIT, 50.0);
    }
    
    // Multiple withdrawals
    for (int i = 0; i < 2; i++) {
        atm.fillUserRequest(UserRequest::REQUEST_WITHDRAW, 25.0);
    }
    
    // Check final balance
    atm.fillUserRequest(UserRequest::REQUEST_BALANCE, 0);
    
    SUCCEED();
}

// Test all request types
TEST_F(ATMTest, AllRequestTypes) {
    atm.viewAccount(1, "");
    
    atm.fillUserRequest(UserRequest::REQUEST_BALANCE, 0);
    atm.fillUserRequest(UserRequest::REQUEST_DEPOSIT, 100.0);
    atm.fillUserRequest(UserRequest::REQUEST_WITHDRAW, 50.0);
    atm.fillUserRequest(UserRequest::REQUEST_TRANSACTIONS, 0);
    
    SUCCEED();
}
