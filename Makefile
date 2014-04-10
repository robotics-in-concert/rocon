
doc: clean sphinx

sphinx:
	rosdoc_lite .

clean:
	rm -rf doc/html
