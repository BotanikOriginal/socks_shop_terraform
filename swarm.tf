resource "null_resource" "swarm_init" {
  depends_on = [yandex_compute_instance.swarm_manager]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install -y docker.io",
      "sudo apt-get install git",
      "sudo git clone https://github.com/BotanikOriginal/socks_shop.git",
      "sudo systemctl start docker",
      "sudo usermod -aG docker rgorin",
      "sudo docker swarm init --advertise-addr ${yandex_compute_instance.swarm_manager.network_interface[0].ip_address}",
      "sudo docker swarm join-token worker -q > /tmp/worker_token.txt",
    ]

    connection {
      type        = "ssh"
      user        = "rgorin"
      private_key = file("/home/rgorin/.ssh/id_rsa")
      host        = yandex_compute_instance.swarm_manager.network_interface[0].nat_ip_address
    }
  }
}

resource "null_resource" "id_rsa" {
  depends_on = [null_resource.swarm_init]
    provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i /home/rgorin/.ssh/id_rsa /home/rgorin/.ssh/id_rsa rgorin@${yandex_compute_instance.swarm_manager.network_interface[0].nat_ip_address}:/home/rgorin/.ssh/"
  }

triggers = {
    always_run = "${timestamp()}"
  }
}


resource "null_resource" "copy_worker_token" {
  depends_on = [null_resource.id_rsa]

  provisioner "remote-exec" {
    inline = [
      "scp -o StrictHostKeyChecking=no /tmp/worker_token.txt rgorin@${yandex_compute_instance.swarm_worker[0].network_interface[0].ip_address}:/home/rgorin/worker_token.txt",
      "scp -o StrictHostKeyChecking=no /tmp/worker_token.txt rgorin@${yandex_compute_instance.swarm_worker[1].network_interface[0].ip_address}:/home/rgorin/worker_token.txt"
    ]

    connection {
      type        = "ssh"
      user        = "rgorin"
      private_key = file("/home/rgorin/.ssh/id_rsa")
      host        = yandex_compute_instance.swarm_manager.network_interface[0].nat_ip_address
    }
  }
}

resource "null_resource" "join_workers" {
  depends_on = [null_resource.copy_worker_token]
  count = length (yandex_compute_instance.swarm_worker)
  provisioner "remote-exec" {
    inline = [
        "sudo apt-get update && sudo apt-get install -y docker.io",
        "sudo systemctl start docker",
        "sudo docker swarm join ${yandex_compute_instance.swarm_manager.network_interface[0].ip_address}:2377 --token $(cat ./worker_token.txt) ",
      ]

    connection {
      type        = "ssh"
      user        = "rgorin"
      private_key = file("/home/rgorin/.ssh/id_rsa")
      host        = element (yandex_compute_instance.swarm_worker[*].network_interface[0].nat_ip_address, count.index)
    }
  }
}

resource "null_resource" "deploy" {
  depends_on = [null_resource.join_workers]

  provisioner "remote-exec" {
    inline = [
      "cd socks_shop",
      "docker stack deploy -c docker-compose.yml socks_shop",
    ]

    connection {
      type        = "ssh"
      user        = "rgorin"
      private_key = file("/home/rgorin/.ssh/id_rsa")
      host        = yandex_compute_instance.swarm_manager.network_interface[0].nat_ip_address
    }
  }
}

