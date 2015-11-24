#include "main.hpp"

int main()
{
	auto result = SHEmptyRecycleBinW(
		nullptr,
		nullptr,
		SHERB_NOCONFIRMATION |
		SHERB_NOPROGRESSUI |
		SHERB_NOSOUND);

	if (result == E_UNEXPECTED) // already empty
		return 0;

	return result;
}