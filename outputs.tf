output "manager_ip" {
  value = yandex_compute_instance.swarm_manager.network_interface[0].ip_address
}

output "manager_public_ip" {
  value = yandex_compute_instance.swarm_manager.network_interface[0].nat_ip_address
}

output "worker_ips" {
  value = [for instance in yandex_compute_instance.swarm_worker : instance.network_interface[0].ip_address]
}

output "worker_public_ips"{
  value = [for instance in yandex_compute_instance.swarm_worker : instance.network_interface[0].nat_ip_address]
}

