terraform {
  required_version = "> 1.9.8"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "> 0.73"
    }
  }
}

provider "yandex" {
  token     = "y0_xxxxxxxxxxxxxxxxxxxxxxxxxxkg"
  cloud_id  = "b1gxxxxxxxxxxxxxxxxxxxxxxxxxxsc"
  folder_id = "b1xxxxxxxxxxxxxx57"
  zone      = "ru-central1-b"
}
