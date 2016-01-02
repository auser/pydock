PREFIX=auser

up:
	docker-compose -p pydock -d up

down:
	docker-compose -p pydock stop

backup:
	docker run --volumes-from pydock_core_1 -v $(pwd):/backup busybox tar cvfz /backup/backup.tar.gz "/home/compute/notebooks"

restore:
  docker run --volumes-from pydock_core_1 -v $(pwd):/backup busybox bash -c "cd /home/compute/notebooks && tar xvf /backup/backup.tar.gz"


clean:
	docker-cleanup
