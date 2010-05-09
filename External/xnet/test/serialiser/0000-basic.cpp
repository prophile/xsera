#include "Test.h"

using namespace XNet;

int main()
{
	uint16_t i16v = 0xBEEF;
	DataSerialiser serialiser;
	serialiser << false << true << true << false << false;
	serialiser.PutWord(2, 2);
	serialiser << i16v;
	serialiser << "Hello.";
	serialiser.Sync();
	std::string value = serialiser.StringValue();
	DataUnserialiser unserialiser(value);
	ASSERT_EQUAL(unserialiser.GetWord(1), false, "bool 1 was bad");
	ASSERT_EQUAL(unserialiser.GetWord(1), true, "bool 2 was bad");
	ASSERT_EQUAL(unserialiser.GetWord(1), true, "bool 3 was bad");
	ASSERT_EQUAL(unserialiser.GetWord(1), false, "bool 4 was bad");
	ASSERT_EQUAL(unserialiser.GetWord(1), false, "bool 5 was bad");
	ASSERT_EQUAL(unserialiser.GetWord(2), 2, "pair was bad");
	unserialiser >> i16v;
	ASSERT_EQUAL(i16v, 0xBEEF, "Got wrong int out, got " << i16v << ", wanted " << 0xBEEF);
	unserialiser >> value;
	ASSERT_EQUAL(value, "Hello.", "Got wrong result out: expected Hello., got " << value);
	return 0;
}
