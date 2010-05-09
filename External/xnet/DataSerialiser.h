#ifndef __XNET_DATA_SERIALISER__
#define __XNET_DATA_SERIALISER__

#include <vector>
#include <string>
#include <inttypes.h>

#if defined(__LITTLE_ENDIAN__) && !defined(__clang__)
#include <arpa/inet.h>
#endif

namespace XNet
{

class DataSerialiser
{
private:
#if defined(__LITTLE_ENDIAN__) && defined(__clang__)
	static uint32_t Big32(uint32_t x)
		{ return __builtin_bswap32(x); }
#elif defined(__LITTLE_ENDIAN__)
	static uint32_t Big32(uint32_t x)
		{ return ntohl(x); }
#else
	static uint32_t Big32(uint32_t x)
		{ return x; }
#endif
	std::vector<uint32_t> words;
	uint32_t currentWord, index;
public:
	DataSerialiser();

	void PutWord(uint32_t value, int significantBits);

	void Sync();
	const void* DataValue(size_t& length) const;
	std::string StringValue() const;

	DataSerialiser& operator<<(bool value)
		{ PutWord(value ? 1 : 0, 1); return *this; }
	DataSerialiser& operator<<(uint8_t value)
		{ PutWord(value, 8); return *this; }
	DataSerialiser& operator<<(int8_t value)
		{ PutWord(value, 8); return *this; }
	DataSerialiser& operator<<(uint16_t value)
		{ PutWord(value, 16); return *this; }
	DataSerialiser& operator<<(int16_t value)
		{ PutWord(value, 16); return *this; }
	DataSerialiser& operator<<(uint32_t value)
		{ PutWord(value, 32); return *this; }
	DataSerialiser& operator<<(int32_t value)
		{ PutWord(value, 32); return *this; }
	DataSerialiser& operator<<(uint64_t value);
	DataSerialiser& operator<<(int64_t value)
		{ return *this << (uint64_t)value; }
	DataSerialiser& operator<<(const std::string& value);
	DataSerialiser& operator<<(const char* value)
		{ return *this << std::string(value); }
	DataSerialiser& operator<<(float value)
		{
			union { float fval; uint32_t ival; } bitcast;
			bitcast.fval = value;
			return *this << bitcast.ival;
		}
	DataSerialiser& operator<<(double value)
		{
			union { double fval; uint64_t ival; } bitcast;
			bitcast.fval = value;
			return *this << bitcast.ival;
		}
};

}

#endif
