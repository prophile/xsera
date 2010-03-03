#ifndef __GAFFILE__
#define __GAFFILE__

#include <string>
#include <map>

class GAFFile
{
private:
	void* _data;
	unsigned long _length;
	int _data_ownership;
	unsigned long _data_base;
	typedef std::map<std::string, std::pair<unsigned long, unsigned long> > EntryList;
	EntryList _entries;
	void Decode();
public:
	GAFFile(void* data, unsigned long length, bool owned)
	: _data(data),
	  _length(length),
	  _data_ownership(owned ? 1 : 0),
	  _data_base(0)
	{
		Decode();
	}
	GAFFile(const std::string& path);
	~GAFFile();

	bool HasFile(const std::string& filename) const
	{
		return _entries.find(filename) != _entries.end();
	}
	const void* GetFile(const std::string& filename, unsigned long& length) const
	{
		EntryList::const_iterator iter = _entries.find(filename);
		if (iter == _entries.end())
		{
			length = 0;
			return 0;
		}
		else
		{
			unsigned long totalOffset = _data_base + iter->second.first;
			length = iter->second.second;
			return (const void*)((const char*)_data + totalOffset);
		}
	}
};

#endif
