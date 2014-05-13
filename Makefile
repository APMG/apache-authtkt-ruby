help:
	@echo 'make [test | all | deps | update]'

all: deps

test: check
check:
	bundle exec rspec

deps:
	bundle install

update:
	bundle update

.PHONY: test check deps update
