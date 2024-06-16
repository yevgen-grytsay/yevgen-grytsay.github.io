
dir:
	mkdir -p ./build

build-devops-cv: dir
	wkhtmltopdf \
		--enable-local-file-access \
		./cv/devops-cv.html ./build/devops-cv.pdf

build-php-cv: dir
	wkhtmltopdf \
		--enable-local-file-access \
		./cv/php-cv.html ./build/php-cv.pdf

build: build-devops-cv build-php-cv

clean:
	rm ./build/devops-cv.pdf ./build/php-cv.pdf
