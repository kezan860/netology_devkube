resource "yandex_compute_instance" "master01" {
  name        = "kube-master-01"
  zone        = "ru-central1-a"
  hostname    = "kube-master-01.kezan86.cloud"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "${var.ubuntu-20-04}"
      name        = "root-master01"
      size = "30"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default.id}"
    nat       = true
  }

  metadata = {
      user-data = "${file("./meta.txt")}"
  }
}
