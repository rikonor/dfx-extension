DFX  ?= dfx
PORT ?= 8123

EXT_NAME ?= dfx-extension
TARGET   ?= debug

DOWNLOAD_URL_TEMPLATE_LOCAL  = http://localhost:$(PORT)/$(EXT_NAME).tar.gz
DOWNLOAD_URL_TEMPLATE_GITHUB = https://github.com/dfinity/dfx-extensions/releases/download/{{tag}}/{{basename}}.{{archive-format}}

clean:
	@rm -rf \
		out www \
		extension.json \
		$(EXT_NAME).tar.gz 

build:
	cargo build

tmpl:
	@sed \
		-e "s|{{NAME}}|$(EXT_NAME)|g" \
		-e "s|{{VERSION}}|0.5.0|g" \
		-e "s|{{HOMEPAGE}}|HOMEPAGE|g" \
		-e "s|{{DOWNLOAD_URL_TEMPLATE}}|$(DOWNLOAD_URL_TEMPLATE_LOCAL)|g" \
			extension.json.tmpl > extension.json

bundle: build tmpl
	@mkdir -p out
	@cp target/$(TARGET)/$(EXT_NAME) out/$(EXT_NAME)
	@cp extension.json out/extension.json
	@tar -czf $(EXT_NAME).tar.gz out
	@rm -r out

	@rm -rf www && mkdir -p www
	@cp $(EXT_NAME).tar.gz www/$(EXT_NAME).tar.gz
	@cp extension.json www/extension.json
	@cp dependencies.json www/dependencies.json

serve: bundle
	@miniserve www \
		-p $(PORT)

check-serve:
	@curl -s --head --fail http://localhost:8123 >/dev/null && echo "Server is up!" || { \
		echo 'Please run "make serve" first' >&2; exit 1; \
	}

install: bundle check-serve
	@$(DFX) extension uninstall $(EXT_NAME) || :
	@$(DFX) extension install \
		--install-as $(EXT_NAME) \
			http://localhost:$(PORT)/extension.json

run: install
	@$(DFX) $(EXT_NAME)
