#include "Test.h"

using namespace XNet;

const uint64_t TEST = 0xFEEDFACECAFEBABEULL;

int main()
{
	uint64_t i64v = TEST;
	DataSerialiser serialiser;
	serialiser << i64v;
	serialiser.Sync();
	std::string value = serialiser.StringValue();
	ASSERT_EQUAL(value.length(), 8, "serialised string had the wrong length: " << value.length());
	DataUnserialiser unserialiser(value);
	unserialiser >> i64v;
	ASSERT_EQUAL(i64v, TEST, "64-bit value was incorrect (expected " << TEST << ", got " << i64v << ")");
	return 0;
}
