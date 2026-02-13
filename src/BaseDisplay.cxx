#include "BaseDisplay.hxx"
#include "ATM.hxx"

#include <iostream>
using namespace std;

void BaseDisplay::showInfoToUser(const char* message)
{
    if (message)
    {
        cout << message ;
    }
}

void BaseDisplay::showBalance(double balance)
{
    cout << " : " << balance << endl;
}

BaseDisplay::DisplayType BaseDisplay::getType() {return SECURE;}
void BaseDisplay::logError(std::string msg) {};

void BaseDisplay::showTransaction(UserRequest request, double amount)
{
    switch (request) {
        case UserRequest::REQUEST_TRANSACTIONS:
            cout << "REQUEST_TRANSACTIONS";
            break;
        case UserRequest::REQUEST_BALANCE:
            cout << "REQUEST_BALANCE";
            break;
        case UserRequest::REQUEST_DEPOSIT:
            cout << "REQUEST_DEPOSIT";
            break;
        case UserRequest::REQUEST_INVALID:
            cout << "REQUEST_INVALID";
            break;
        case UserRequest::REQUEST_WITHDRAW:
            cout << "REQUEST_WITHDRAW";
            break;
    }
    cout << " : " << amount << endl;
}
