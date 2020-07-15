PROJDIR := src

help:
	@echo
	@echo '  dev     - Switch to development branch'
	@echo '  dist    - Switch to distribution branch'
	@echo '  clean   - Removes all temporary server-build files (not ./bin)'
	@echo '  plugins - Clean and rebuild plugin cache'
	@echo '  clean-all - Rebuild everything (not ./bin)'
	@echo
	@echo '  server  - Start lektor server with live change updates'
	@echo '  build   - Build deployable website into ./bin'
	@echo '  deploy  - Custom rsync command to sync ./bin to remote server'
	@echo
	@echo
	@echo '  find-links - Search for cross reference between recipes'
	@echo

define switch_to
	@echo Set source to $(1)
	@rm $(PROJDIR)/content/recipes; ln -s $(1) $(PROJDIR)/content/recipes
endef

# Clean

dev:
	$(call switch_to, '../../data/development/')

dist: 
	$(call switch_to, '../../data/distribution/')

clean:
	@echo 'Cleaning output'
	@cd '$(PROJDIR)' && lektor clean --yes -v

plugins:
	@echo 'Cleaning plugins'
	@cd '$(PROJDIR)' && lektor plugins flush-cache && lektor plugins list

clean-all: clean plugins

# Build

server:
	@cd '$(PROJDIR)' && lektor server

build:
	@cd '$(PROJDIR)' && \
	lektor build --output-path ../bin --buildstate-path ../build-state -f ENABLE_APPCACHE

deploy:
	@echo
	@echo 'Warning: This will not(!) build but sync all files in ./bin'
	@( read -p "Continue? [y/N]: " sure && case "$$sure" in [yY]) true;; *) false;; esac )
	@echo # --dry-run
	rsync -rclzv --exclude=.lektor --exclude=.DS_Store --delete bin/ vps:/srv/http/recipe-lekture

# Helper methods on all recipes

find-links:
	@echo
	@cd '$(PROJDIR)/content/recipes' && \
	find */*.lr -exec grep --color=auto -i ".\.\./[^ ]*" -o {} + \
	|| echo 'nothing found.'
	@echo
