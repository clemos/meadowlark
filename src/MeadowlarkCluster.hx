package ;

import js.Node;
import js.node.Cluster;
import js.node.stdio.Console;

class MeadowlarkCluster
{
	var cluster : Cluster;
	var console : Console;

	public function new() {
		cluster = js.node.Cluster.cluster;
		console = Node.console;
	}

	public function start() {
		if(cluster.isMaster) {
			var cpus : Array<Dynamic> = cast js.node.Os.cpus();
			for (cpu in cpus) startWorker();

			cluster.on('disconnect', function(worker : ClusterWorker) {
				console.log('CLUSTER: Worker %d disconnected from the cluster.', worker.id);
			});

			// when a worker dies (exits), create a worker to replace it
			cluster.on('exit', function(worker, code, signal) {
				console.log('CLUSTER: Worker %d died with exit code %d (%s)',
					worker.id, code, signal);
				startWorker();
			});
		} else {
			new Meadowlark().start();
		}
	}

	private function startWorker() {
		var worker = cluster.fork();
		console.log('CLUSTER: Worker %d started', worker.id);
	}
}