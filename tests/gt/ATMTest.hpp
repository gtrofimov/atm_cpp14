#include "gtest/gtest.h"

#include "ATM.hxx"
#include "Account.hxx"
#include "Bank.hxx"
#include "BaseDisplay.hxx"

#include <string>
#include <tuple>
#include <vector>

namespace {
class TestDisplay : public BaseDisplay {
public:
  void showInfoToUser(const char* message) override {
    ++infoCalls;
    std::string value = message ? message : "";
    lastInfo = value;
    infoMessages.push_back(value);
  }

  void showBalance(double balance) override {
    balances.push_back(balance);
  }

  void showTransaction(UserRequest request, double amount) override {
    transactions.emplace_back(request, amount);
  }

  int infoCalls = 0;
  std::string lastInfo;
  std::vector<std::string> infoMessages;
  std::vector<double> balances;
  std::vector<std::tuple<UserRequest, double>> transactions;
};
}  // namespace

TEST(ATM, exampleFunctionShowsMessage) {
  ::testing::Test::RecordProperty("req", "AGT-9");
  ::testing::Test::RecordProperty("cpptest_filename", __FILE__);
  Bank bank;
  TestDisplay display;
  ATM atm(&bank, &display);

  atm.exampleFunction();

  ASSERT_EQ(display.infoCalls, 1);
  ASSERT_EQ(display.lastInfo, "This is a dummy function");
}

TEST(ATM, viewAccountInvalidShowsMessage) {
  ::testing::Test::RecordProperty("req", "AGT-9");
  ::testing::Test::RecordProperty("cpptest_filename", __FILE__);
  Bank bank;
  TestDisplay display;
  ATM atm(&bank, &display);

  atm.viewAccount(0, "bad");

  ASSERT_EQ(display.infoCalls, 1);
  ASSERT_EQ(display.lastInfo, "Invalid account");
}

TEST(ATM, fillUserRequestWithoutAccountDoesNothing) {
  ::testing::Test::RecordProperty("req", "AGT-9");
  ::testing::Test::RecordProperty("cpptest_filename", __FILE__);
  Bank bank;
  TestDisplay display;
  ATM atm(&bank, &display);

  atm.fillUserRequest(UserRequest::REQUEST_BALANCE, 0.0);

  ASSERT_EQ(display.infoCalls, 0);
  ASSERT_TRUE(display.balances.empty());
  ASSERT_TRUE(display.transactions.empty());
}

TEST(ATM, fillUserRequestBalanceAndUpdates) {
  ::testing::Test::RecordProperty("req", "AGT-9");
  ::testing::Test::RecordProperty("cpptest_filename", __FILE__);
  Bank bank;
  TestDisplay display;
  ATM atm(&bank, &display);

  Account* account = bank.addAccount();
  account->setPassword("pw");
  atm.viewAccount(account->getAccountNumber(), "pw");

  atm.fillUserRequest(UserRequest::REQUEST_BALANCE, 0.0);

  ASSERT_EQ(display.infoCalls, 1);
  ASSERT_EQ(display.lastInfo, "Current Balance");
  ASSERT_EQ(display.balances.size(), 1U);
  ASSERT_EQ(display.balances.front(), 0.0);
}

TEST(ATM, fillUserRequestDepositWithdrawAndTransactions) {
  ::testing::Test::RecordProperty("req", "AGT-9");
  ::testing::Test::RecordProperty("cpptest_filename", __FILE__);
  Bank bank;
  TestDisplay display;
  ATM atm(&bank, &display);

  Account* account = bank.addAccount();
  account->setPassword("pw");
  atm.viewAccount(account->getAccountNumber(), "pw");

  atm.fillUserRequest(UserRequest::REQUEST_DEPOSIT, 50.0);
  atm.fillUserRequest(UserRequest::REQUEST_WITHDRAW, 20.0);
  atm.fillUserRequest(UserRequest::REQUEST_TRANSACTIONS, 0.0);

  ASSERT_GE(display.infoMessages.size(), 2U);
  ASSERT_EQ(display.infoMessages[0], "Updated Balance");
  ASSERT_EQ(display.infoMessages[1], "Updated Balance");
  ASSERT_EQ(display.balances.size(), 2U);
  ASSERT_EQ(display.balances[0], 50.0);
  ASSERT_EQ(display.balances[1], 30.0);
  ASSERT_EQ(display.transactions.size(), 4U);
}
