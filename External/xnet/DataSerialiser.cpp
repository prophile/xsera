#include "DataSerialiser.h"
#include <stdio.h>
#include <assert.h>

namespace XNet
{

DataSerialiser::DataSerialiser()
: currentWord(0), index(0)
{
}

void DataSerialiser::Sync()
{
	if (index == 0)
		return;
	if (index != 32)
		currentWord <<= 32 - index;
	words.push_back(Big32(currentWord));
	currentWord = index = 0;
}

const void* DataSerialiser::DataValue(size_t& length) const
{
	length = words.size() * 4;
	return (const void*)&words[0];
}

std::string DataSerialiser::StringValue() const
{
	size_t len;
	const char* bytes = (const char*)DataValue(len);
	std::string rv(bytes, len);
	return rv;
}

DataSerialiser& DataSerialiser::operator<<(uint64_t value)
{
	return *this << ((uint32_t)(value >> 32)) << ((uint32_t)(value));
}

DataSerialiser& DataSerialiser::operator<<(const std::string& value)
{
	unsigned len = value.length();
	bool shorthand = len < 32;
	if (shorthand)
	{
		for (unsigned i = 0; i < len; ++i)
		{
			if (value[i] & 0x80)
			{
				shorthand = false;
				break;
			}
		}
	}
	PutWord(shorthand ? 1 : 0, 1);
	if (shorthand)
		PutWord(len, 5);
	else
		PutWord(value.length(), 24);
	for (unsigned i = 0; i < len; ++i)
	{
		PutWord(value.at(i), shorthand ? 7 : 8);
	}
	return *this;
}

static uint32_t MaskToLowOrder(uint32_t value, int sigbits)
{
	return value & ((1 << sigbits)-1);
}

void DataSerialiser::PutWord(uint32_t value, int sigbits)
{
	// case where it fits
	assert(sigbits > 0);
	int remaining = 32 - index;
	if (sigbits <= remaining)
	{
		index += sigbits;
		if (sigbits == 32)
			currentWord = 0;
		else
			currentWord <<= sigbits;
		currentWord |= MaskToLowOrder(value, sigbits);
		if (index == 32)
		{
			Sync();
		}
	}
	else
	{
		// split it
		uint32_t high = value >> (sigbits-remaining);
		PutWord(high, remaining);
		PutWord(value, sigbits-remaining);
	}
}

}
