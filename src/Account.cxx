#include "Account.hxx"
#include "ATM.hxx"
#include "BaseDisplay.hxx"

#include <utility>

// C++11/14: move constructor
Account::Account(Account&& a):
    myAccountNumber(a.myAccountNumber),
    myBalance(a.myBalance),
    myPassword(std::move(a.myPassword)),
    myTransactions(std::move(a.myTransactions))
{

}

Account::Account(double initial): myBalance(initial)
{
	if (initial) { // parasoft-suppress MISRACPP2023-7_0_2-a "ok in this case"
	    myTransactions.emplace_back(UserRequest::REQUEST_DEPOSIT, initial);
	} else {
	    myTransactions.emplace_back(UserRequest::REQUEST_WITHDRAW, initial);
	}
}

double Account::deposit(double amount)
{
    myTransactions.emplace_back(UserRequest::REQUEST_DEPOSIT, amount);

    myBalance += amount;
    return (getBalance());
}


double Account::debit(double amount)
{
    myTransactions.emplace_back(UserRequest::REQUEST_WITHDRAW, amount);
    myBalance -= amount;
    return (getBalance());
}

int Account::listTransactions(BaseDisplay& display, UserRequest type) {

	int transactionsCount = 0;

	if (display.getType() == BaseDisplay::UNKNOWN) {
		display.logError("Unknown display");
		return transactionsCount;
	}

	// C++11/14: for-each statement:
	for(auto&& tuple : myTransactions) {
		display.showBalance(std::get<1>(tuple));
	}


	// C++11/14: lambda expression
	std::for_each(
			myTransactions.begin(),
			myTransactions.end(),
			[display, &transactionsCount, type](std::tuple<UserRequest, double> tuple) mutable
			{
				display.showTransaction(std::get<0>(tuple), std::get<1>(tuple));
				if (std::get<0>(tuple) == type) {
				    transactionsCount++;
				}
			});
    return transactionsCount;
}
