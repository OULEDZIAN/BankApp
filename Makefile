PROJECT = BankApp/BankApp.xcodeproj
SCHEME = BankApp
DESTINATION = platform=iOS Simulator,name=iPhone 16

lint:
	swiftlint lint

test:
	xcodebuild test \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME)" \
		-destination '$(DESTINATION)' \
		-enableCodeCoverage YES \
		-resultBundlePath coverage.xcresult \
		-quiet

coverage:
	xcrun xccov view --report --json coverage.xcresult \
		| python3 -c "import json,sys; data=json.load(sys.stdin); pct=data['lineCoverage']*100; print(f'Coverage: {pct:.1f}%'); sys.exit(0 if pct >= 70 else 1)"

clean:
	rm -rf ~/Library/Developer/Xcode/DerivedData
	rm -f coverage.xcresult

all: lint test coverage
