CXX=g++
INCLUDES=-IPlugins -I. -ISystem
CXXFLAGS=-Wall -Wno-reorder -fomit-frame-pointer -fno-rtti -Os $(INCLUDES)

all: libxnet.a

check: libxnet.a
	cd test ; ./run-tests

libxnet.a: Peer.o DataSerialiser.o DataUnserialiser.o Message.o Plugin.o Plugins/Sequencing.o Plugins/Reliability.o Plugins/SimulateLag.o Plugins/Logging.o Plugins/Splitting.o Plugins/Ordering.o Plugins/AllowingConnections.o System/SocketProvider.o System/LocalOnly.o
	rm -f $@ ; ar -c -q -s $@ $^

Peer.o: Peer.cpp XNet.h DataUnserialiser.h DataSerialiser.h System/SocketProvider.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

DataSerialiser.o: DataSerialiser.cpp DataSerialiser.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

DataUnserialiser.o: DataUnserialiser.cpp DataUnserialiser.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

Message.o: Message.cpp XNet.h DataUnserialiser.h DataSerialiser.h System/SocketProvider.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

Plugin.o: Plugin.cpp XNet.h DataUnserialiser.h DataSerialiser.h System/SocketProvider.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

Plugins/Sequencing.o: Plugins/Sequencing.cpp Plugins/Sequencing.h XNet.h DataUnserialiser.h DataSerialiser.h System/SocketProvider.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

Plugins/Reliability.o: Plugins/Reliability.cpp Plugins/Reliability.h XNet.h DataUnserialiser.h DataSerialiser.h System/SocketProvider.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

Plugins/Ordering.o: Plugins/Ordering.cpp Plugins/Ordering.h XNet.h DataUnserialiser.h DataSerialiser.h System/SocketProvider.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

Plugins/AllowingConnections.o: Plugins/AllowingConnections.cpp Plugins/AllowingConnections.h XNet.h DataUnserialiser.h DataSerialiser.h System/SocketProvider.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

Plugins/SimulateLag.o: Plugins/SimulateLag.cpp Plugins/SimulateLag.h XNet.h DataUnserialiser.h DataSerialiser.h System/SocketProvider.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

Plugins/Logging.o: Plugins/Logging.cpp Plugins/Logging.h XNet.h DataUnserialiser.h DataSerialiser.h System/SocketProvider.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

Plugins/Splitting.o: Plugins/Splitting.cpp Plugins/Splitting.h XNet.h DataUnserialiser.h DataSerialiser.h System/SocketProvider.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

System/SocketProvider.o: System/SocketProvider.cpp System/SocketProvider.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

System/LocalOnly.o: System/LocalOnly.cpp System/LocalOnly.h System/SocketProvider.h
	$(CXX) -c $(CXXFLAGS) -o $@ $<

clean:
	rm -f *.o Plugins/*.o libxnet.a System/*.o
