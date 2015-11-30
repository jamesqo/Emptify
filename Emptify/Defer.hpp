#pragma once

#include <utility>

#define CONCAT(left, right) left##right

#if defined(__COUNTER__)
#define MAKE_UNIQUE_NAME CONCAT(__defer__, __COUNTER__)
#elif defined(__LINE__)
#define MAKE_UNIQUE_NAME CONCAT(__defer__, __LINE__)
#else
#error The __COUNTER__ and __LINE__ directives are not defined.
#endif

#define DEFER(code) auto MAKE_UNIQUE_NAME = ::emptify::Defer([&] { code; });

namespace emptify
{
    template <typename Function>
    class Deferral
    {
    private:
        Function f_;
    public:
        Deferral(Function&& f) noexcept
            : f_(std::forward<Function>(f))
        {
        }

        ~Deferral() { f_(); }
    };

    template <typename Function>
    Deferral<Function> Defer(Function&& f) noexcept
    {
        // No idea why std::forward is needed here, 
        // but I think it's supposed to create a 
        // wrapper rvalue reference for a function.
        return Deferral<Function>(std::forward<Function>(f));
    }
}
