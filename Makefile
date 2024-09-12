#
# Maror Blog Makefile
# (c) 2024 Mike Doyle
#
# Helps me blog without having to remember a bunch of hugo commands.
#

.PHONY: post image preview commit push

export POPBROWSER = open
export LOCALHUGO = http://localhost:1313
export EDITOR = "vim"
post:
	hugo new "posts/$(name).md"
	hugo server -D --quiet &
	$(POPBROWSER) $(LOCALHUGO)
	$(EDITOR) "content/posts/$(name).md"

image:
	cp $(path) public/images/$(dest)
