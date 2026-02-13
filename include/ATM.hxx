#ifndef ATM_HXX
#define ATM_HXX

#include "Bank.hxx"

#include <string>

class BaseDisplay;
class Account;

// C++11 enum class
enum class UserRequest {
    REQUEST_INVALID = 0,
    REQUEST_BALANCE = 1,
    REQUEST_DEPOSIT,
    REQUEST_WITHDRAW,
    REQUEST_TRANSACTIONS,
};

class ATM
{
    public:


        ATM(Bank* bank, BaseDisplay* display);
        void viewAccount(int accountNumber, std::string password);
        void fillUserRequest(UserRequest request, double amount);

    private:

        void showBalance();
        void showTransations();
        void makeDeposit(double amount);
        void withdraw(double amount);

       	Account* myCurrentAccount;
        Bank* myBank;
        BaseDisplay* myDisplay;

};

#endif // ATM_HXX
