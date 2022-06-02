For parallel interactive SSH sessions:

	sudo apt install clusterssh
	cssh <host_or_cluster1> [<host_or_cluster2> ...]

For parallel scp:

	sudo apt install pssh
	pscp [-r] /source/on/local /dest/on/all/hosts/or/clusters
