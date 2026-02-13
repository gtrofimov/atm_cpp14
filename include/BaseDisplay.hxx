#ifndef BASE_DISPLAY_HXX
#define BASE_DISPLAY_HXX

#include <cstdint>
#include <string>

enum class UserRequest : std::uint8_t; // parasoft-suppress MISRACPP2023-6_0_3-a "Project API types are intentionally in the global namespace."

class BaseDisplay // parasoft-suppress MISRACPP2023-6_0_3-a "Project API types are intentionally in the global namespace."
{

    public:
        enum DisplayType {UNKNOWN, SECURE};

		// C++11/14: noexcept specifier
        BaseDisplay() noexcept = default;
        ~BaseDisplay() noexcept = default;

        BaseDisplay(const BaseDisplay&) = delete;
        BaseDisplay& operator=(const BaseDisplay&) = delete;
        BaseDisplay(BaseDisplay&&) = delete;
        BaseDisplay& operator=(BaseDisplay&&) = delete;

        virtual void showInfoToUser(const char* message);
        virtual void showBalance(double balance);
        virtual void showTransaction(UserRequest request, double amount);
        virtual enum DisplayType getType();
        virtual void logError(std::string msg);
};

#endif // BASE_DISPLAY_HXX
