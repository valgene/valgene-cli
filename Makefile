DARTANALYZER_FLAGS=--fatal-warnings

build: lib/*dart test/*dart bin/*dart deps checks
	pub run test_coverage

deps: pubspec.yaml
	pub get

checks:
	dartanalyzer ${DARTANALYZER_FLAGS} lib/ bin/
	dartfmt -n --set-exit-if-changed lib/ test/ bin/

reformatting:
	dartfmt -w lib/ test/ bin/

build-local: reformatting build
	genhtml -o coverage coverage/lcov.info
	open coverage/index.html

publish:
	pub publish