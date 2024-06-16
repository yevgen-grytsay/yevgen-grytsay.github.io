
dir:
	mkdir -p ./build

build-devops-resume: dir
	wkhtmltopdf \
		--enable-local-file-access \
		./cv/devops-resume.html ./build/devops-resume.pdf

build-php-resume: dir
	wkhtmltopdf \
		--enable-local-file-access \
		./cv/php-resume.html ./build/php-resume.pdf

build: build-devops-resume build-php-resume

clean:
	rm ./build/devops-resume.pdf ./build/php-resume.pdf
