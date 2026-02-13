#ifndef BANK_HXX
#define BANK_HXX

#include <string>
#include <vector>
using namespace std;

class Account;
class Bank
{
    public:

        Bank();
        ~Bank();

        // C++11/14: auto return type
        auto getAccount(int num, string password) -> Account*;
        Account* addAccount();

    private:

        vector<Account*> myAccounts;
        int myCurrentAccountNumber;
};

#endif // BANK_HXX
