#include "DataUnserialiser.h"
#include <assert.h>
#include <stdio.h>

namespace XNet
{

static uint32_t bitswap(uint32_t v)
{
	// swap odd and even bits
	v = ((v >> 1) & 0x55555555) | ((v & 0x55555555) << 1);
	// swap consecutive pairs
	v = ((v >> 2) & 0x33333333) | ((v & 0x33333333) << 2);
	// swap nibbles ... 
	v = ((v >> 4) & 0x0F0F0F0F) | ((v & 0x0F0F0F0F) << 4);
	// swap bytes
	v = ((v >> 8) & 0x00FF00FF) | ((v & 0x00FF00FF) << 8);
	// swap 2-byte long pairs
	v = ( v >> 16             ) | ( v               << 16);
	return v;
}

void DataUnserialiser::NextWord()
{
	bitIndex = 0;
	if (words.size() == nextWord)
	{
		// early exit
		currentWord = 0;
		return;
	}
	currentWord = bitswap(words[nextWord++]);
}

void DataUnserialiser::Init(const void* data, size_t length)
{
	assert(length % 4 == 0);
	const uint32_t* wordPtr = (const uint32_t*)data;
	words.reserve(length / 4);
	for (size_t i = 0; i < (length/4); ++i)
	{
		words.push_back(Big32(wordPtr[i]));
	}
	nextWord = 0;
	NextWord();
}

static uint32_t MaskToLowOrder(uint32_t value, int sigbits)
{
	return value & ((1 << sigbits)-1);
}

uint32_t DataUnserialiser::GetWord(int significantBits)
{
	int remaining = 32 - bitIndex;
	if (significantBits <= remaining)
	{
		// simple case
		bitIndex += significantBits;
		uint32_t result = MaskToLowOrder(currentWord, significantBits);
		currentWord >>= significantBits;
		if (bitIndex == 32)
		{
			NextWord();
		}
		result = bitswap(result);
		result >>= 32 - significantBits;
		return result;
	}
	else
	{
		// complex case
		// get high order
		int highBits = remaining;
		int lowBits = significantBits - remaining;
		uint32_t highValue = GetWord(highBits);
		uint32_t lowValue = GetWord(lowBits);
		uint32_t result = (highValue << lowBits) | lowValue;
		return result;
	}
}

DataUnserialiser::DataUnserialiser(const void* data, size_t length)
{
	Init(data, length);
}

DataUnserialiser::DataUnserialiser(const std::string& data)
{
	Init(data.data(), data.length());
}

DataUnserialiser& DataUnserialiser::operator>>(uint64_t& value)
{
	uint64_t result = 0;
	uint32_t result32 = 0;
	*this >> result32;
	result = ((uint64_t)result32) << 32ULL;
	*this >> result32;
	result |= (uint64_t)result32;
	value = result;
	return *this;
}

DataUnserialiser& DataUnserialiser::operator>>(std::string& value)
{
	bool isShorthand = GetWord(1);
	uint32_t length = GetWord(isShorthand ? 5 : 24);
	value.resize(length);
	for (uint32_t i = 0; i < length; ++i)
	{
		value.at(i) = GetWord(isShorthand ? 7 : 8);
	}
	return *this;
}

}
