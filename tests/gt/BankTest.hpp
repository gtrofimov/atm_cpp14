#include "gtest/gtest.h"
#include "Account.hxx"
#include "Bank.hxx"


TEST(Bank, addAccount) {
  ::testing::Test::RecordProperty("req", "AGT-7");
  ::testing::Test::RecordProperty("cpptest_filename", __FILE__);
  Bank theBank;
  Account * acct = theBank.addAccount();
  ASSERT_TRUE(nullptr != acct);
}

TEST(Bank, addAccountMultiple) {
  ::testing::Test::RecordProperty("req", "AGT-7");
  ::testing::Test::RecordProperty("cpptest_filename", __FILE__);
  int count = 10;
  Bank theBank;
  for (int i = 0; i < count; i ++) {
    Account * acct = theBank.addAccount();
    ASSERT_TRUE(nullptr != acct);
    ASSERT_EQ(acct->getAccountNumber(), i);
  }
}

TEST(Bank, getAccount_1) {
  ::testing::Test::RecordProperty("cpptest_filename", __FILE__);
  int num = 0;
  string password = "";
  Bank theBank;
  Account * acct = theBank.getAccount(num, password);
  ASSERT_FALSE(nullptr != acct);
}


TEST(Bank, getAccount_2) {
  ::testing::Test::RecordProperty("cpptest_filename", __FILE__);
  int num = 0;
  string password = "";
  Bank theBank;
  theBank.addAccount();
  Account * acct = theBank.getAccount(num, password);
  ASSERT_TRUE(nullptr != acct);
}

TEST(Bank, getAccount_3) {
  ::testing::Test::RecordProperty("cpptest_filename", __FILE__);
  int num = 0;
  string password = "test";
  Bank theBank;
  theBank.addAccount();
  Account * acct = theBank.getAccount(num, password);
  ASSERT_TRUE(nullptr != acct);
}
