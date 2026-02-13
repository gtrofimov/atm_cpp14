#include "Bank.hxx"
#include "Account.hxx"

#include <cstddef>
#include <memory>
#include <utility>

Bank::Bank() : myAccounts(), myCurrentAccountNumber(0)
{
}

// Get acount number. Only return valid object if password is correct
Account* Bank::getAccount(std::int32_t num, std::string password)
{
    Account* userAccount = nullptr;
    if (num >= 0)
    {
        std::size_t index = static_cast<std::size_t>(num);
        if (myAccounts.size() > index)
        {
            userAccount = myAccounts[index].get();
        }
    }
    if (userAccount != nullptr)
    {
        const char* storedPassword = userAccount->getPassword();
        if ((storedPassword[0] != '\0') && (password.compare(storedPassword) != 0))
        {
            // account wrong if password does not match
            userAccount = nullptr;
        }
    }

    // No account with this number/password exists.
    return userAccount;
}

// Create a new account and return a reference to it
Account* Bank::addAccount()
{
    auto userAccount = std::make_unique<Account>();
    userAccount->setAccountNumber(myCurrentAccountNumber++);
    Account* accountPtr = userAccount.get();
    myAccounts.push_back(std::move(userAccount));
    return accountPtr;
}

