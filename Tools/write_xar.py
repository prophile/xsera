import os
import sys
import struct
import os.path

fileHeader = ""
fileBlockData = ""
numFiles = 0

def write_file ( path ):
	global numFiles
	global fileHeader
	global fileBlockData
	numFiles = numFiles + 1
	fp = open(path, 'r')
	fileContent = fp.read()
	fp.close()
	offset = len(fileBlockData)
	length = len(fileContent)
	fileBlockData += fileContent
	fileHeader += struct.pack('>IIH', offset, length, len(path))
	fileHeader += path
	print 'A ' + path + '\n'

def write_directory_recursive ( directory ):
	fileList = os.listdir(directory)
	for fileEntry in fileList:
		if os.path.isdir(directory + '/' + fileEntry):
			write_directory_recursive(directory + '/' + fileEntry)
		else:
			write_file(directory + '/' + fileEntry)

targetFile = sys.argv[1]
sourceDirectory = sys.argv[2]

write_directory_recursive(sourceDirectory)

fp = open(targetFile, 'w')
fp.write('XARK')
fp.write(struct.pack('>H', numFiles))
fp.write(fileHeader)
fp.write(fileBlockData)


