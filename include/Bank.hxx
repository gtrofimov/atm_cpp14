#ifndef BANK_HXX
#define BANK_HXX

#include <cstdint>
#include <memory>
#include <string>
#include <vector>

class Account; // parasoft-suppress MISRACPP2023-6_0_3-a "Project API types are intentionally in the global namespace."
class Bank // parasoft-suppress MISRACPP2023-6_0_3-a "Project API types are intentionally in the global namespace."
{
    public:

        Bank();
        ~Bank() = default;

        Bank(const Bank&) = delete;
        Bank& operator=(const Bank&) = delete;
        Bank(Bank&&) = delete;
        Bank& operator=(Bank&&) = delete;

        // C++11/14: auto return type
        auto getAccount(std::int32_t num, std::string password) -> Account*;
        Account* addAccount();

    private:

        std::vector<std::unique_ptr<Account>> myAccounts;
        std::int32_t myCurrentAccountNumber;
};

#endif // BANK_HXX
