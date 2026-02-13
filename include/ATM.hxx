#ifndef ATM_HXX
#define ATM_HXX

#include "Bank.hxx"

#include <cstdint>
#include <string>

class BaseDisplay; // parasoft-suppress MISRACPP2023-6_0_3-a "Project API types are intentionally in the global namespace."
class Account; // parasoft-suppress MISRACPP2023-6_0_3-a "Project API types are intentionally in the global namespace."

// C++11 enum class
enum class UserRequest : std::uint8_t { // parasoft-suppress MISRACPP2023-6_0_3-a "Project API types are intentionally in the global namespace."
    REQUEST_INVALID = 0,
    REQUEST_BALANCE = 1,
    REQUEST_DEPOSIT,
    REQUEST_WITHDRAW,
    REQUEST_TRANSACTIONS,
};

class ATM // parasoft-suppress MISRACPP2023-6_0_3-a "Project API types are intentionally in the global namespace."
{
    public:


        ATM(Bank* bank, BaseDisplay* display);
        void viewAccount(std::int32_t accountNumber, std::string password);
        void fillUserRequest(UserRequest request, double amount);
        void exampleFunction();

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
