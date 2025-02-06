DFX ?= dfx

EXT_NAME ?= dfx-extension
TARGET   ?= debug

clean:
	rm -rf \
		out www $(EXT_NAME).tar.gz

build:
	cargo build

bundle: build
	mkdir -p out
	cp target/$(TARGET)/$(EXT_NAME) out/$(EXT_NAME)
	cp extension.json out/extension.json
	tar -czf $(EXT_NAME).tar.gz out
	rm -r out

	rm -rf www && mkdir -p www
	cp $(EXT_NAME).tar.gz www/$(EXT_NAME).tar.gz
	cp extension.json www/extension.json
	cp dependencies.json www/dependencies.json

serve: bundle
	miniserve www \
		-p 8123

install: bundle
	$(DFX) extension install \
		--install-as $(EXT_NAME) \
			http://localhost:8123/extension.json

run: install
	$(DFX) $(EXT_NAME)
