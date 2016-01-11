up:
	docker-compose -p pydock up -d

down:
	docker-compose -p pydock stop

backup:
	docker run --volumes-from pydock_core_1 -v $(CURDIR):/backup ubuntu bash -c "cd /home/compute/notebooks && tar cvfz /backup/backup.tar.gz ."

restore:
	docker run --volumes-from pydock_core_1 -v $(CURDIR):/backup ubuntu bash -c "cd /home/compute/notebooks && tar xfz /backup/backup.tar.gz"


clean:
	docker-cleanup
