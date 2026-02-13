#include "BaseDisplay.hxx"
#include "ATM.hxx"

#include <iostream>

void BaseDisplay::showInfoToUser(const char* message)
{
    if (message != nullptr)
    {
        std::cout << message ;
    }
}

void BaseDisplay::showBalance(double balance)
{
    std::cout << " : " << balance << std::endl;
}

BaseDisplay::DisplayType BaseDisplay::getType() {return SECURE;}
void BaseDisplay::logError(std::string msg) { (void)msg; };

void BaseDisplay::showTransaction(UserRequest request, double amount)
{
    switch (request) {
        case UserRequest::REQUEST_TRANSACTIONS:
            std::cout << "REQUEST_TRANSACTIONS";
            break;
        case UserRequest::REQUEST_BALANCE:
            std::cout << "REQUEST_BALANCE";
            break;
        case UserRequest::REQUEST_DEPOSIT:
            std::cout << "REQUEST_DEPOSIT";
            break;
        case UserRequest::REQUEST_INVALID:
            std::cout << "REQUEST_INVALID";
            break;
        case UserRequest::REQUEST_WITHDRAW:
            std::cout << "REQUEST_WITHDRAW";
            break;
        default:
            break;
    }
    std::cout << " : " << amount << std::endl;
}
