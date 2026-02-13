#ifndef ACCOUNT_HXX
#define ACCOUNT_HXX

#include <algorithm>
#include <string>
#include <tuple>
#include <vector>
#include <functional>
#include <utility>
//added comment
#include "ATM.hxx"

class Account
{
    public:
    
		// C++11/14
        Account() = default;

        // C++11/14: move constructor
        Account(Account&&);

        explicit Account(double initial);

        auto getBalance() const
        {
            myTransactions.emplace_back(UserRequest::REQUEST_BALANCE, myBalance);

            return (myBalance);
        }

        // C++14: auto return type
        auto getAccountNumber() const
        {
            return (myAccountNumber);
        }

        void setAccountNumber(int num)
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
            std::for_each(myTransactions.begin(), myTransactions.end(), t);
        }


        int listTransactions(BaseDisplay&, UserRequest type);
    private:

        // C++11/14: deleted special functions:
        Account(const Account&) = delete;
        Account& operator=(const Account&) = delete;

        int myAccountNumber = 0;
        double myBalance = 0;
        std::string myPassword;

        mutable std::vector<std::tuple<UserRequest, double>> myTransactions;
};

#endif // ACCOUNT_HXX
