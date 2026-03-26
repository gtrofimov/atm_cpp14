#include "ATM.hxx"
#include "Account.hxx"
#include "BaseDisplay.hxx"

using std::string;

ATM::ATM(Bank* bank, BaseDisplay* display)
{
    myBank = bank;
    myDisplay = display;
}
  
void ATM::viewAccount(int accountNumber, string password)
{
    if ( !(myCurrentAccount = myBank->getAccount(accountNumber, password)) )
    {
        myDisplay->showInfoToUser("Invalid account");
    }
}

void ATM::fillUserRequest(UserRequest request, double amount)
{
    if (myCurrentAccount)
        switch (request)
        {
            case UserRequest::REQUEST_BALANCE:
                showBalance(); break;
            case UserRequest::REQUEST_DEPOSIT:
                makeDeposit(amount); break;
            case UserRequest::REQUEST_WITHDRAW:
                withdraw(amount); break;
            case UserRequest::REQUEST_TRANSACTIONS:
                showTransations();
        }
}

void ATM::showBalance()
{
    double bal = myCurrentAccount->getBalance();
    myDisplay->showInfoToUser("Current Balance");
    myDisplay->showBalance(bal);
}

void ATM::showTransations()
{
    myCurrentAccount->forEachTransaction(
    		[this] (const std::tuple<UserRequest, double>& tuple)
    	{
        myDisplay->showTransaction(std::get<0>(tuple), std::get<1>(tuple));
    });
}


void ATM::makeDeposit(double amount)
{
    auto bal = myCurrentAccount->deposit(amount);
    myDisplay->showInfoToUser("Updated Balance");
    myDisplay->showBalance(bal);
}

void ATM::withdraw(double amount)
{
    auto bal = myCurrentAccount->deposit(amount * -1.0);
    myDisplay->showInfoToUser("Updated Balance");
    myDisplay->showBalance(bal);
}

void ATM::resetSession()
{
    bool wasActive = isAccountActive();
    myCurrentAccount = nullptr;
    if (wasActive) {
        myDisplay->showInfoToUser("Session terminated");
    } else {
        myDisplay->showInfoToUser("No active session to terminate");
    }
}

bool ATM::isAccountActive() const
{
    return (myCurrentAccount != nullptr) && (myCurrentAccount->getBalance() >= 0.0);
}

// Example function with intentional MISRA C++ 2023 violations for demonstration
int ATM::calcFee(int accountType, int amount)
{
    int fee;                          // MISRA 8.1.1: variable not initialized (uninitialized read risk)
    int* p = NULL;                    // MISRA 7.11.1: use of NULL macro instead of nullptr

    if (accountType == 1) {
        fee = amount * 0.02;          // MISRA 8.3.1: implicit conversion from double to int
        p = &fee;
        goto done;                    // MISRA 9.2.1: use of goto statement
    } else {
        fee = amount * 0.05;
        p = &fee;
    }

done:
    return *p;
}

