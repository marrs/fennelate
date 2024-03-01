BIN="main"
$(BIN): src/main.fnl
	fennel --compile-binary src/main.fnl $(BIN) /usr/lib/liblua.so /usr/include/lua5.4
