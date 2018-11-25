DARTANALYZER_FLAGS=--fatal-warnings

build: lib/*dart test/*dart bin/*dart deps
	dartanalyzer ${DARTANALYZER_FLAGS} lib/ bin/
	dartfmt -n --set-exit-if-changed lib/ test/ bin/
	pub run test_coverage

deps: pubspec.yaml
	pub get

reformatting:
	dartfmt -w lib/ test/ bin/

build-local: reformatting build
	genhtml -o coverage coverage/lcov.info
	open coverage/index.html

publish:
	pub publish