@all: clean build install

clean:
	rm -f cocoaseeds-*.gem

build:
	gem build cocoaseeds.gemspec

install:
	sudo gem install cocoaseeds-*.gem

push: clean build
	gem push cocoaseeds-*.gem
