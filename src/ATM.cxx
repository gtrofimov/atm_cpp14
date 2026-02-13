#include "ATM.hxx"
#include "Account.hxx"
#include "BaseDisplay.hxx"

ATM::ATM(Bank* bank, BaseDisplay* display)
    : myCurrentAccount(nullptr),
      myBank(bank),
      myDisplay(display)
{
}
  
void ATM::viewAccount(std::int32_t accountNumber, std::string password)
{
    myCurrentAccount = myBank->getAccount(accountNumber, password);
    if (myCurrentAccount == nullptr)
    {
        myDisplay->showInfoToUser("Invalid account");
    }
}

void ATM::fillUserRequest(UserRequest request, double amount)
{
    if (myCurrentAccount != nullptr)
    {
        switch (request)
        {
            case UserRequest::REQUEST_BALANCE:
                showBalance();
                break;
            case UserRequest::REQUEST_DEPOSIT:
                makeDeposit(amount);
                break;
            case UserRequest::REQUEST_WITHDRAW:
                withdraw(amount);
                break;
            case UserRequest::REQUEST_TRANSACTIONS:
                showTransations();
                break;
            default:
                break;
        }
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

// Dummy function to demonstrate adding new methods
void ATM::exampleFunction()
{
    myDisplay->showInfoToUser("This is a dummy function");
}