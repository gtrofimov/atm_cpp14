
#include "gtest/gtest.h"

#include "AccountTest.hpp"
#include "BankTest.hpp"
#include "BaseDisplayTest.hpp"


int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}

