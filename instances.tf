data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "swarm_manager" {
  name        = "swarm-manager"
  zone        = "ru-central1-b"
  platform_id = "standard-v1"

  resources {
    cores   = 2
    memory  = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      size = 10
    }
  }

  network_interface {
    subnet_id = "e2lk35jd6lpg88l51ssn"
    nat       = true
  }
  metadata = {
    user-data= "${file("./meta.yml")}"
  }
}

resource "yandex_compute_instance" "swarm_worker" {
  count       = 2
  name        = "swarm-worker-${count.index + 1}"
  zone        = "ru-central1-b"
  
  platform_id = "standard-v1"

  resources {
    cores   = 2
    memory  = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      size = 10
    }
  }

  network_interface {
    subnet_id = "e2lk35jd6lpg88l51ssn"
    nat       = true

  }
 
  metadata = {
    user-data= "${file("./meta.yml")}"
  }
}

