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

