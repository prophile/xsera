#include "GAFFile.h"
#include <stdlib.h>
#include <assert.h>
#include <inttypes.h>

#ifdef __BIG_ENDIAN__
#define BE32(x) (x)
#define BE16(x) (x)
#else
#ifdef __clang__
#define BE32(val) __builtin_bswap32(val)
#else
static uint32_t BE32(uint32_t val)
{
	union
	{
		char bytes[4];
		uint32_t longVal;
	} initial, converted;
	initial.longVal = val;
	converted.bytes[0] = initial.bytes[3];
	converted.bytes[1] = initial.bytes[2];
	converted.bytes[2] = initial.bytes[1];
	converted.bytes[3] = initial.bytes[0];
	return converted.longVal;
}
#endif
static uint16_t BE16(uint16_t val)
{
	return (val << 8) | (val >> 8);
}
#endif

void GAFFile::Decode()
{
	// check magic number
	assert(!memcmp(_data, "THEGAME!", 8));
	// read file count
	uint32_t count = BE32(((uint32_t*)_data)[2]);
	// read files
	const char* cdata = (const char*)_data;
	cdata += 12;
	for (uint32_t i = 0; i < count; ++i)
	{
		uint16_t length = BE16(*(uint16_t*)cdata);
		cdata += 2;
		std::string name(cdata, length);
		while ((unsigned long)cdata % 4 != 0)
			++cdata;
		uint32_t offset = BE32(*(uint32_t*)cdata);
		cdata += 4;
		uint32_t dlength = BE32(*(uint32_t*)cdata);
		cdata += 4;
		_entries.insert(std::make_pair(name, std::make_pair((unsigned long)offset, (unsigned long)dlength)));
	}
	_data_base = cdata - (const char*)_data;
	_data_base += 15;
	_data_base /= 16;
	_data_base *= 16;
}

GAFFile::~GAFFile()
{
	if (_data_ownership == 1)
	{
		free(_data);
	}
}

GAFFile::GAFFile(const std::string& path)
{
	// TODO: mmap-based implementation
	FILE* fp = fopen(path.c_str(), "rb");
	assert(fp);
	fseek(fp, 0, SEEK_END);
	_length = ftell(fp);
	_data = malloc(_length);
	fread(_data, _length, 1, fp);
	fclose(fp);
	_data_ownership = 1;
	Decode();
}
