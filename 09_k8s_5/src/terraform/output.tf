output "internal_ip_address_master01_yandex_cloud" {
  value = "${yandex_compute_instance.master01.network_interface.0.ip_address}"
}
