battery-notifications: battery-notifications.cpp
	$(CXX) $< -O2 -flto -march=native $(shell pkg-config --cflags libnotify) $(shell pkg-config --libs libnotify fmt) -o $@
	strip $@

