PREFIX=auser

base:
	cd deploy/base && docker build -t ${PREFIX}/base .

pyenv:
	cd deploy/pyenv && docker build -t ${PREFIX}/pyenv .

ipython:
	cd deploy/ipython && docker build -t ${PREFIX}/ipython .

torch:
	cd deploy/torch && docker build -t ${PREFIX}/torch .

opencv:
	cd deploy/opencv && docker build -t ${PREFIX}/opencv .

all: base pyenv ipython torch opencv

clean:
	docker-cleanup
