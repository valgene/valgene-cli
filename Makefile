build: lib/*dart test/*dart bin/*dart
	dartanalyzer lib/ bin/
	dartfmt -w lib/ test/ bin/
	pub run test_coverage
	genhtml -o coverage coverage/lcov.info
	open coverage/index.html