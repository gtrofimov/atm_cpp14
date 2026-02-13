#ifndef ACCOUNT_HXX
#define ACCOUNT_HXX

#include <algorithm>
#include <cstdint>
#include <functional>
#include <string>
#include <tuple>
#include <utility>
#include <vector>

#include "ATM.hxx"

class Account // parasoft-suppress MISRACPP2023-6_0_3-a "Project API types are intentionally in the global namespace."
{
    public:
    
		// C++11/14
        Account() = default;

        // C++11/14: move constructor
        Account(Account&&) noexcept;

        ~Account() noexcept;

        explicit Account(double initial);

        auto getBalance() const
        {
            myTransactions.emplace_back(UserRequest::REQUEST_BALANCE, myBalance);

            return (myBalance);
        }

        // C++14: auto return type
        auto getAccountNumber() const -> std::int32_t
        {
            return (myAccountNumber);
        }

        void setAccountNumber(std::int32_t num)
        {
            myAccountNumber = num;
        }

        void setPassword(const char* password)
        {
            myPassword = password;
        }

        const char* getPassword()
        {
            return (myPassword.data());
        }   
 
        double deposit(double amount);
        
        double debit(double amount);

        template <typename T>
        void forEachTransaction(T t)
        {
            static_cast<void>(std::for_each(myTransactions.begin(), myTransactions.end(), t));
        }

        std::int32_t listTransactions(BaseDisplay&, UserRequest type);
    private:

        // C++11/14: deleted special functions:
        Account(const Account&) = delete;
        Account& operator=(const Account&) = delete;

        std::int32_t myAccountNumber = 0;
        double myBalance = 0;
        std::string myPassword;

        mutable std::vector<std::tuple<UserRequest, double>> myTransactions;
};

#endif // ACCOUNT_HXX
