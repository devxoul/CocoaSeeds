@all: clean build install

clean:
	rm cocoaseeds-*.gem

build:
	gem build cocoaseeds.gemspec

install:
	sudo gem install cocoaseeds-*.gem
